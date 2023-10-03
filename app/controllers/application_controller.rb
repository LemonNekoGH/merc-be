class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from ApplicationErrors::ApplicationError, with: :application_error
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique

  def login(user)
    session[:user_address] = user.address
  end

  def logout
    session[:user_address] = nil
  end

  def current_user
    @current_user ||= User.find_by(address: session[:user_address])
  end

  # @param code [Integer]
  # @param message [String]
  # @param data [Object, nil]
  # @param status [Symbol, nil]
  def make_response(code, message, data, status = nil)
    render json: {
      code:,
      message:,
      data:
    }, status:
  end

  # @raise [ApplicationErrors::ApplicationError]
  def authenticate_user!
    raise ApplicationErrors::ApplicationError.new(:unauthorized, 401, 'login required') if @current_user.nil?
  end

  def verify_message!(message, signature, address)
    public_key = Eth::Signature.personal_recover message, signature
    address_recovered = Eth::Util.public_key_to_address public_key
    return unless address.casecmp(address_recovered.to_s) != 0

    raise ApplicationErrors::ApplicationError.new(:bad_request, 400,
                                                  'cannot verify signature')
  end

  def record_not_found(error)
    case error.model.to_s
    when 'User'
      err_user_not_found
    else
      application_error(ApplicationErrors::ApplicationError.new(:not_found, 40_400, error.message))
    end
  end

  def record_not_unique(error)
    case error.message
    when /index_users_on_address/
      err_user_exists
    when /index_users_on_nickname/
      err_nickname_exists
    else
      application_error(ApplicationErrors::ApplicationError.new(:conflict, 40_900, error.message))
    end
  end

  def application_error(error)
    make_response error.code, error.message, nil, error.status
  end

  private

  def err_user_not_found
    application_error(ApplicationErrors::ApplicationError.new(:not_found, 40_401, 'user not found'))
  end

  def err_user_exists
    application_error(ApplicationErrors::ApplicationError.new(:conflict, 40_901, 'user already exists'))
  end

  def err_nickname_exists
    application_error(ApplicationErrors::ApplicationError.new(:conflict, 40_902, 'nickname already exists'))
  end
end
