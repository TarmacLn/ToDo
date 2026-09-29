class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: :authenticate

  # POST /auth/login
  def authenticate
    auth_token = AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_response({ auth_token: auth_token })
  end

  # GET /auth/logout
  def logout
    JwtDenylist.create!(jti: token_payload[:jti], exp: Time.zone.at(token_payload[:exp]))
    json_response({ message: Message.logged_out })
  end

  private

  def auth_params
    params.permit(:email, :password)
  end
end
