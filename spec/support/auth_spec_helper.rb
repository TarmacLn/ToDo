module AuthSpecHelper
  # A valid token for the given user
  def token_generator(user_id)
    JsonWebToken.encode(user_id: user_id)
  end

  # A token that expired 10 seconds ago
  def expired_token_generator(user_id)
    JsonWebToken.encode({ user_id: user_id }, 10.seconds.ago)
  end

  # Request headers with a valid token for `user` (define `user` with let)
  def valid_headers
    {
      "Authorization" => token_generator(user.id),
      "Content-Type" => "application/json"
    }
  end

  # Request headers without a token
  def invalid_headers
    {
      "Authorization" => nil,
      "Content-Type" => "application/json"
    }
  end
end

RSpec.configure do |config|
  config.include AuthSpecHelper
end
