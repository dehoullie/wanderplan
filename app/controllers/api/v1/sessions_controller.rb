# frozen_string_literal: true

class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  before_action :configure_sign_in_params, only: [:create]
  respond_to :json

  def create
    user = User.find_by(email: params.dig(:user, :email))
    if user&.valid_password?(params.dig(:user, :password))
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      response.set_header('Authorization', "Bearer #{token}")
      render json: { user: user }, status: :ok
    else
      render json: { error: "Invalid login" }, status: :unauthorized
    end
  end

  def me
    Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
    Rails.logger.info "Current user: #{current_user.inspect}"
    if current_user
      render json: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name
      }
    else
      render json: { error: "Not logged in" }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { user: resource, token: request.env['warden-jwt_auth.token'] }, status: :ok
    else
      render json: { error: "Invalid login", params: params }, status: :unprocessable_entity
    end
  end

  def respond_to_on_destroy
    head :no_content
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end
