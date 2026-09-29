require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:headers) { { "Content-Type" => "application/json" } }
  let(:valid_attributes) do
    { name: "Ioanna", email: "ioanna@example.com", password: "password123", password_confirmation: "password123" }
  end

  describe "POST /signup" do
    context "when the request is valid" do
      before { post "/signup", params: valid_attributes.to_json, headers: headers }

      it "creates a new user" do
        expect(User.find_by(email: "ioanna@example.com")).to be_present
      end

      it "returns status 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns a success message and a token" do
        expect(json["message"]).to match(/Account created successfully/)
        expect(json["auth_token"]).not_to be_nil
      end
    end

    context "when the request is invalid" do
      before { post "/signup", params: {}.to_json, headers: headers }

      it "does not create a user" do
        expect(User.count).to eq(0)
      end

      it "returns status 422 with the validation errors" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to match(/Password can't be blank/)
        expect(json["message"]).to match(/Name can't be blank/)
        expect(json["message"]).to match(/Email can't be blank/)
      end
    end

    context "when the email is already taken" do
      before do
        create(:user, email: "ioanna@example.com")
        post "/signup", params: valid_attributes.to_json, headers: headers
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to match(/Email has already been taken/)
      end
    end
  end
end
