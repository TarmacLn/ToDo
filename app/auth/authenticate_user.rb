# Checks an email and password and returns a token for that user
class AuthenticateUser
  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id)
  end

  private

  attr_reader :email, :password

  def user
    # authenticate_by takes the same time whether or not the email exists
    User.authenticate_by(email: email, password: password) ||
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
  end
end
