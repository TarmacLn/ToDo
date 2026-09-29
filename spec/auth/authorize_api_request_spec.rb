require "rails_helper"

RSpec.describe AuthorizeApiRequest do
  let(:user) { create(:user) }

  describe "#call" do
    context "with a valid token" do
      it "returns the user" do
        request = described_class.new("Authorization" => token_generator(user.id))

        expect(request.call[:user]).to eq(user)
      end
    end

    context "without a token" do
      it "raises MissingToken" do
        expect { described_class.new({}).call }
          .to raise_error(ExceptionHandler::MissingToken, /Missing token/)
      end
    end

    context "with a token for a user that no longer exists" do
      it "raises InvalidToken" do
        request = described_class.new("Authorization" => token_generator(0))

        expect { request.call }
          .to raise_error(ExceptionHandler::InvalidToken, /Invalid token/)
      end
    end

    context "with an expired token" do
      it "raises InvalidToken" do
        request = described_class.new("Authorization" => expired_token_generator(user.id))

        expect { request.call }
          .to raise_error(ExceptionHandler::InvalidToken, /Signature has expired/)
      end
    end

    context "with a malformed token" do
      it "raises InvalidToken" do
        request = described_class.new("Authorization" => "foobar")

        expect { request.call }.to raise_error(ExceptionHandler::InvalidToken)
      end
    end
  end
end
