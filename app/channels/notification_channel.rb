# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for params[:address]

    # show latest pending request
    pending = ChatRequests.get_incoming params[:address]
    unless pending.nil?
      from = User.find_by!(address: pending[:from_address])
      to = User.find_by!(address: pending[:to_address])
      broadcast_to params[:address], { type: 'request', id: chat_in_progress.id, from:, to: }
      return
    end

    # auto enter chat if not exit
    chat_in_progress = Chat.chat_in_progress params[:address]
    broadcast_to params[:address], { type: 'accept', id: chat_in_progress.id } unless chat_in_progress.nil?
  end

  # @param data [Hash]
  def receive(data)
    if data['type'] == 'reject'
      ChatRequests.reject data['request']
      request = ChatRequests.find_by id: data['request']
      broadcast_to request.from_address, { type: 'reject', reason: 'Your request has been rejected' }

      return
    end

    if data['type'] == 'cancel'
      ChatRequests.reject data['request']
      request = ChatRequests.find_by id: data['request']
      broadcast_to request.from_address, { type: 'reject', reason: 'This request has been canceled' }

      return
    end

    if data['type'] == 'accept'
      # check request time
      request = ChatRequests.find_by id: data['request']
      if request.created_at.before?(Time.now - 5.minutes)
        ChatRequests.reject(data['request'])
        broadcast_to request.to_address, { type: 'reject', reason: 'This request has been expired' }
        return
      end

      if request.canceled
        ChatRequests.reject(data['request'])
        broadcast_to request.to_address, { type: 'reject', reason: 'This request was canceled' }
        return
      end

      ChatRequests.accept(data['request'])
      # create a chat
      chat = Chat.create({ from_address: request.from_address, to_address: request.to_address })

      # send chat id
      broadcast_to request.from_address, { type: 'accept', id: chat.id }
      broadcast_to request.to_address, { type: 'accept', id: chat.id }

      return
    end

    if data['type'] == 'request'
      from = data['from']
      to = data['to']

      # TODO: use redis to check expiration
      if ChatRequests.user_has_pending_request? to
        broadcast_to from, { type: 'reject', reason: 'Target has a pending request' }
        return
      end

      chat_in_progress = Chat.chat_in_progress to
      # auto reject when other side is in a chat
      unless chat_in_progress.nil?
        broadcast_to from, { type: 'reject', reason: 'Target is chatting with others' }
        return
      end

      chat_in_progress = Chat.chat_in_progress from
      unless chat_in_progress.nil?
        broadcast_to from, { type: 'reject', reason: "You can't send request when you are chatting" }
        return
      end

      # create a request, used to check expiration
      request = ChatRequests.create!({ from_address: from, to_address: to, message: data['message'] })
      from_user = User.find_by!(address: from)
      broadcast_to from, { type: 'request_id', id: request.id }
      broadcast_to to, { type: 'request', from: from_user, id: request.id, message: data['message'] }
    end
  end
end
