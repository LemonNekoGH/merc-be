# frozen_string_literal: true

require 'json'

class HallChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'hall'

    data = []
    MessageToHall.all.each { |msg|
      data.push(JSON.parse(msg.message))
    }

    ActionCable.server.broadcast 'hall', data
  end

  def receive(data)
    MessageToHall.create!({ message: JSON.dump(data) })
    ActionCable.server.broadcast 'hall', data
  end
end
