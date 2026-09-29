class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  # Every endpoint needs a valid token unless the controller skips this
  before_action :authorize_request
  attr_reader :current_user, :token_payload

  private

  def authorize_request
    result = AuthorizeApiRequest.new(request.headers).call
    @current_user = result[:user]
    @token_payload = result[:payload]
  end
end
