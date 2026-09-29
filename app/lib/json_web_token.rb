class JsonWebToken
  # Tokens are signed with the app's secret key
  HMAC_SECRET = Rails.application.secret_key_base

  # Create a signed token that expires after 24 hours by default
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, HMAC_SECRET)
  end

  # Read a token back into a hash, e.g. decode(token)[:user_id]
  def self.decode(token)
    body = JWT.decode(token, HMAC_SECRET)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError => e
    # Also covers expired tokens (JWT::ExpiredSignature)
    raise ExceptionHandler::InvalidToken, e.message
  end
end
