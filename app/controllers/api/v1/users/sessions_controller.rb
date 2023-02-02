class Api::V1::Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    current_user ? log_in_success : log_in_failure
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split.last, ENV.fetch('DEVISE_JWT_SECRET_KEY')).first
      # ENV.fetch('DEVISE_JWT_SECRET_KEY')
      # Rails.application.credentials.dig(:devise, :jwt_secret_key)
      current_user = User.find(jwt_payload['sub'])
      current_user ? log_out_success : log_out_failure
    else
    log_out_failure
    end
  end

  def log_in_success
    render json: {
      status: 200,
      message: 'Logged in sucessfully.',
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def log_in_failure
    render json: {
      status: 422,
      message: "Log in failure. #{resource.errors.full_messages.to_sentence}",
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }, status: :unprocessable_entity
  end

  def log_out_success
    render json: {
      status: { code: :ok, message: 'Logged out successfully.' }
    }, status: :ok
  end

  def log_out_failure
    render json: {
      status: { message: "Couldn't log out." }
    }, status: :unprocessable_entity
  end
end
