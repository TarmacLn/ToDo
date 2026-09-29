# Finds the user from the token in the Authorization header
class AuthorizeApiRequest
  def initialize(headers = {})
    @headers = headers
  end

  def call
    { user: user }
  end

  private

  attr_reader :headers

  def user
    User.find(decoded_token[:user_id])
  rescue ActiveRecord::RecordNotFound
    raise ExceptionHandler::InvalidToken, Message.invalid_token
  end

  def decoded_token
    JsonWebToken.decode(http_auth_header)
  end

  # Accepts both "Bearer <token>" and just "<token>"
  def http_auth_header
    token = headers["Authorization"].to_s.split(" ").last
    raise ExceptionHandler::MissingToken, Message.missing_token if token.blank?

    token
  end
end
