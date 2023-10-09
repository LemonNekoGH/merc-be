# frozen_string_literal: true

class ChatRequests < ApplicationRecord
  # @param address [String]
  def user_has_pending_request?(address)
    get_incoming(address).nil?
  end

  # @return [ChatRequests]
  def get_incoming(address)
    ChatRequests.find_by(to: address, accepted: nil)
  end

  # @param [Integer] id
  def expired?(id)
    ChatRequests.find_by(id: id).created_at.before?(Time.now - 5.seconds)
  end

  # @param [Integer] id
  def accept(id)
    ChatRequests.update(id: id, accepted: true)
  end

  # @param [Integer] id
  def reject(id)
    ChatRequests.update(id: id, accepted: false)
  end
end
