require "rails_helper"

RSpec.describe AuthenticateUser do
  let(:user) { create(:user) }

  describe "#call" do
    context "with valid credentials" do
      it "returns a token for the user" do
        token = described_class.new(user.email, user.password).call

        expect(JsonWebToken.decode(token)[:user_id]).to eq(user.id)
      end
    end

    context "with a wrong password" do
      it "raises AuthenticationError" do
        expect { described_class.new(user.email, "wrong").call }
          .to raise_error(ExceptionHandler::AuthenticationError, /Invalid credentials/)
      end
    end

    context "with an unknown email" do
      it "raises AuthenticationError" do
        expect { described_class.new("nobody@example.com", "password123").call }
          .to raise_error(ExceptionHandler::AuthenticationError, /Invalid credentials/)
      end
    end
  end
end
