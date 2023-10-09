# frozen_string_literal: true

class HallChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'hall'
    # TODO: send last 30 messages to user
  end

  def receive(data)
    # TODO: save to database
    ActionCable.server.broadcast 'hall', data
  end
end
