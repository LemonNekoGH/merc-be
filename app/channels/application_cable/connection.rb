# frozen_string_literal: true

# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      @current_user = find_verified_user
    end

    private
    def find_verified_user
      if (verified_user = User.find_by(address: cookies.encrypted[:_session]['user_address']))
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
