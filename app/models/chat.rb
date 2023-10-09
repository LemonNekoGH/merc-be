# frozen_string_literal: true

class Chat < ApplicationRecord
  # @param [Integer] id
  # @param [String] address
  # @param [Integer] response
  # @param [String] response_reason
  def user_response(id, address, response, response_reason)
    chat = Chat.find_by!(id: id)
    if chat.from_address == address
      chat.from_response = response
      chat.from_response_reason = response_reason
    else
      chat.to_response = response
      chat.to_response_reason = response_reason
    end
    Chat.update(chat)
  end

  # @param [String] address
  def chat_in_progress(address)
    Chat.where(from: address).or(to: address).find_by(end_at: nil)
  end

  # @param [Integer] id
  # @param [String] address
  def exit_chat(id, address)
    chat = Chat.find_by!(id: id)
    chat.end_at = Time.now
    chat.end_by = address
    Chat.update(chat)
  end
end
