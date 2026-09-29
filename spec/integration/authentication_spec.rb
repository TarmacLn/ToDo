require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  path "/signup" do
    post "Sign up" do
      tags "Authentication"
      description "Creates a new account and returns a token, so the user is logged in right away."
      consumes "application/json"
      produces "application/json"
      security []
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Ioanna" },
          email: { type: :string, format: :email, example: "ioanna@example.com" },
          password: { type: :string, format: :password, example: "password123" },
          password_confirmation: { type: :string, format: :password, example: "password123" }
        },
        required: %w[name email password]
      }

      response "201", "Account created" do
        schema "$ref" => "#/components/schemas/signup_response"
        let(:body) do
          { name: "Ioanna", email: "ioanna@example.com", password: "password123", password_confirmation: "password123" }
        end

        run_test!
      end

      response "422", "Missing or invalid data, or the email is already taken" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { name: "", email: "ioanna@example.com", password: "" } }

        run_test!
      end
    end
  end

  path "/auth/login" do
    post "Log in" do
      tags "Authentication"
      description "Checks the email and password and returns a token that is valid for 24 hours."
      consumes "application/json"
      produces "application/json"
      security []
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "ioanna@example.com" },
          password: { type: :string, format: :password, example: "password123" }
        },
        required: %w[email password]
      }

      let!(:user) { create(:user, email: "ioanna@example.com", password: "password123") }

      response "200", "Logged in" do
        schema "$ref" => "#/components/schemas/auth_token"
        let(:body) { { email: "ioanna@example.com", password: "password123" } }

        run_test!
      end

      response "401", "Wrong email or password" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { email: "ioanna@example.com", password: "wrong" } }

        run_test!
      end
    end
  end

  path "/auth/logout" do
    get "Log out" do
      tags "Authentication"
      description "Revokes the token used for this request. After logging out, that token returns 401."
      produces "application/json"

      let(:user) { create(:user) }

      response "200", "Logged out" do
        schema "$ref" => "#/components/schemas/message"
        let(:Authorization) { "Bearer #{token_generator(user.id)}" }

        run_test!
      end

      response "401", "Missing, invalid, expired or already revoked token" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { "Bearer invalid-token" }

        run_test!
      end
    end
  end
end
