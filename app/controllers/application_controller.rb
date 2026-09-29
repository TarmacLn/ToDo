class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  # Every endpoint needs a valid token unless the controller skips this
  before_action :authorize_request
  attr_reader :current_user

  private

  def authorize_request
    @current_user = AuthorizeApiRequest.new(request.headers).call[:user]
  end
end
