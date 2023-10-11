# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = Chat.find_by!(id: params[:id])
    stream_for @chat
  end

  def received(data)
    if data['type'] == 'exit'
      # user exit
      Chat.exit_chat data['id'], data['from']
      broadcast_to @chat, { type: 'exit' }

      return
    end
    # save to database
    MessageToUser.create!({ chat_id: params[:id], from: data['from'] })
    broadcast_to @chat, data
  end
end
