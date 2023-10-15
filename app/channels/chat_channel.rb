# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = Chat.find_by({ id: params[:id] })
    if @chat.nil?
      reject
      return
    end

    # chat is not from or to this user
    user_from_response = User.find_by({ address: params[:user] })
    if @chat.from_address != user_from_response.address && @chat.to_address != user_from_response.address
      reject
      return
    end

    # chat ended
    if @chat.from_address == user_from_response
      user_response = @chat.from_response
      user_response_reason = @chat.from_response_reason
    else
      user_response = @chat.to_response
      user_response_reason = @chat.to_response_reason
    end
    if @chat.end_by != nil && @chat.end_at != nil && user_response != nil && user_response_reason != nil
      reject
      return
    end

    stream_for @chat

    # send chat info
    from = User.find_by({ address: @chat.from_address })
    to = User.find_by({ address: @chat.to_address })

    broadcast_to @chat, {
      type: 'info',
      messages: MessageToUser.where({ chat_id: @chat.id }).all,
      end: @chat.end_at != nil,
      end_by: @chat.end_by,
      from:,
      to:
    }
  end

  def receive(data)
    if data['type'] == 'exit'
      # user exit
      Chat.exit_chat data['id'], data['from']
      broadcast_to @chat, { type: 'exit', from: data['from'] }

      return
    end
    # save to database
    MessageToUser.create({ chat_id: params[:id], from: data['from'], message: data['message'] })
    broadcast_to @chat, data
  end
end
