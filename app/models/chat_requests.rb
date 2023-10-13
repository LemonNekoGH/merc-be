# frozen_string_literal: true

class ChatRequests < ApplicationRecord
  # @param address [String]
  def self.user_has_pending_request?(address)
    !get_incoming(address).nil?
  end

  # @return [ChatRequests]
  def self.get_incoming(address)
    ChatRequests.find_by(to_address: address, accepted: nil, canceled: nil)
  end

  # @param [Integer] id
  def self.expired?(id)
    !ChatRequests.find_by(id: id).created_at.before?(Time.now - 5.minutes)
  end

  # @param [Integer] id
  def self.accept(id)
    ChatRequests.update({ id: id, accepted: true })
  end

  # @param [Integer] id
  def self.reject(id)
    ChatRequests.update({ id: id, accepted: false })
  end

  # @param [Integer] id
  def self.cancel(id)
    ChatRequests.update({ id: id, canceled: true })
  end
end
