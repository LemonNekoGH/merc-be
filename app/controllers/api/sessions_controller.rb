# frozen_string_literal: true

module Api
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: %i[index]

    # GET /api/sessions
    def show
      @user = current_user

      make_response 0, '', @user, :created
    end

    # POST /api/sessions
    def create
      address = login_params[:address]
      @user = User.find_by!(address:)
      raise ApplicationErrors.ApplicationError.new(not_found, 404, 'user not found') if @user.nil?

      # check message and signature
      verify_message!(login_params[:message], login_params[:sign_hex], address)

      login(@user)

      make_response 0, '', @user, :created
    end

    # DELETE /api/sessions
    def destroy
      logout
    end

    # GET /api/sessions/message_for_login
    def create_message
      make_response 0, '', 'Welcome back to MERC'
    end

    private

    def login_params
      params.require(:user).permit(:address, :message, :sign_hex)
    end
  end
end
