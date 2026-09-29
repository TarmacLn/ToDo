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
end
