# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    # GET /api/users/:id
    def show
      @user = User.find(params[:id])
      authorize @user

      make_response 0, '', @user
    end

    # POST /api/users
    def create
      address = create_params[:address]
      verify_message! create_params[:message], create_params[:sign_hex], address

      authorize User
      @user = User.create!({ address: })

      login(@user)

      make_response 0, '', @user, :created
    end

    # PATCH /api/users/:id
    def update
      @user = User.find(params[:id])
      authorize @user
      @user.update!(user_params)

      make_response 0, '', @user
    end

    # GET /api/users/message_for_signup
    def create_message
      @code = 0
      @data = 'Welcome to MERC!'
      @message = ''

      make_response 0, '', 'Welcome to MERC!', :not_found
    end

    def create_params
      params.require(:user).permit(:address, :message, :sign_hex)
    end

    def user_params
      params.require(:user).permit(:nickname, :gender, :id, :avatar)
    end
  end
end
