# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:address]

    # show latest pending request
    pending = ChatRequests.get_incoming params[:address]
    from = User.find_by!(address: pending[:from_address])
    to = User.find_by!(address: pending[:to_address])
    broadcast_to params[:address], { type: 'request', id: chat_in_progress.id, from:, to: }

    # auto enter chat if not exit
    chat_in_progress = Chat.chat_in_progress params[:address]
    broadcast_to params[:address], { type: 'accept', id: chat_in_progress.id } unless chat_in_progress.nil?
  end

  # @param data [Hash]
  def received(data)
    from = data['from']['address']
    to = data['to']['address']

    if data['type'] == 'reject'
      ChatRequests.reject(data['id'])
      broadcast_to from, { type: 'reject', reason: 'user_reject' }

      return
    end

    if data['type'] == 'accept'
      # check request time
      unless ChatRequests.expired?(data['id'])
        ChatRequests.reject(data['id'])
        broadcast_to from, { type: 'reject', reason: 'expired' }
        return
      end

      ChatRequests.accept(data['id'])
      # create a chat
      chat = Chat.create(from: from, to: to)

      # send chat id
      broadcast_to from, { type: 'accept', id: chat.id }
      broadcast_to to, { type: 'accept', id: chat.id }

      return
    end

    if data['type'] == 'request'
      # TODO: use redis to check expiration
      if ChatRequests.user_has_pending_request? to
        ChatRequests.reject(data['id'])
        broadcast_to from, { type: 'accept', reason: 'pending' }
        return
      end

      chat_in_progress = Chat.chat_in_progress to
      # auto reject when other side is in a chat
      unless chat_in_progress.nil?
        ChatRequests.reject(data['id'])
        broadcast_to from, { type: 'reject', reason: 'chatting' }
        return
      end

      # create a request, used to check expiration
      request = ChatRequests.create(from: from, to: to)
      broadcast_to to, { type: 'request', from: data['from'], to: data['to'], id: request.id }
    end
  end
end
