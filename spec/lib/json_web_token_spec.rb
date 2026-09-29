require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode and .decode" do
    it "returns the original payload after a round trip" do
      token = JsonWebToken.encode(user_id: 42)

      expect(JsonWebToken.decode(token)[:user_id]).to eq(42)
    end

    it "gives every token a unique id (jti)" do
      first = JsonWebToken.decode(JsonWebToken.encode(user_id: 42))
      second = JsonWebToken.decode(JsonWebToken.encode(user_id: 42))

      expect(first[:jti]).to be_present
      expect(first[:jti]).not_to eq(second[:jti])
    end

    it "raises InvalidToken when the token has expired" do
      token = JsonWebToken.encode({ user_id: 42 }, 10.seconds.ago)

      expect { JsonWebToken.decode(token) }
        .to raise_error(ExceptionHandler::InvalidToken, /Signature has expired/)
    end

    it "raises InvalidToken when the token is not a valid JWT" do
      expect { JsonWebToken.decode("not-a-token") }
        .to raise_error(ExceptionHandler::InvalidToken)
    end
  end
end
