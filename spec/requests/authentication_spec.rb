require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let!(:user) { create(:user) }
  let(:headers) { { "Content-Type" => "application/json" } }

  describe "POST /auth/login" do
    context "with valid credentials" do
      before do
        post "/auth/login", params: { email: user.email, password: user.password }.to_json, headers: headers
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a token for the user" do
        expect(JsonWebToken.decode(json["auth_token"])[:user_id]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      before do
        post "/auth/login", params: { email: user.email, password: "wrong" }.to_json, headers: headers
      end

      it "returns status 401 with an error message" do
        expect(response).to have_http_status(:unauthorized)
        expect(json["message"]).to match(/Invalid credentials/)
      end
    end
  end

  describe "GET /auth/logout" do
    context "with a valid token" do
      let(:headers) { valid_headers }

      before { get "/auth/logout", headers: headers }

      it "returns status 200 with a message" do
        expect(response).to have_http_status(:ok)
        expect(json["message"]).to match(/Logged out successfully/)
      end

      it "stops the token from working" do
        get "/todos", headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json["message"]).to match(/Token has been revoked/)
      end

      it "does not affect other tokens of the same user" do
        get "/todos", headers: { "Authorization" => token_generator(user.id) }

        expect(response).to have_http_status(:ok)
      end
    end

    context "without a token" do
      before { get "/auth/logout", headers: invalid_headers }

      it "returns status 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
