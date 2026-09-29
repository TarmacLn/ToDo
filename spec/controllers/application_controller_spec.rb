require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  # A throwaway controller to test the shared behaviour of ApplicationController
  controller do
    skip_before_action :authorize_request

    def index
      json_response({ message: "ok" })
    end

    def show
      json_response(Todo.find(params[:id]))
    end

    def create
      json_response(Todo.create!(title: ""), :created)
    end
  end

  describe "authorization" do
    # Inherit from ApplicationController directly, so the token check still runs
    controller(ApplicationController) do
      def index
        json_response({ user_id: current_user.id })
      end
    end

    let(:user) { create(:user) }

    it "sets current_user from a valid token" do
      request.headers["Authorization"] = token_generator(user.id)
      get :index

      expect(response).to have_http_status(:ok)
      expect(json["user_id"]).to eq(user.id)
    end

    it "returns status 401 when the token is missing" do
      get :index

      expect(response).to have_http_status(:unauthorized)
      expect(json["message"]).to match(/Missing token/)
    end

    it "returns status 401 when the token is invalid" do
      request.headers["Authorization"] = "foobar"
      get :index

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "json_response" do
    it "renders the object as JSON with status 200" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(json).to eq("message" => "ok")
    end
  end

  describe "when a record is not found" do
    it "returns status 404 with an error message" do
      get :show, params: { id: 0 }

      expect(response).to have_http_status(:not_found)
      expect(json["message"]).to match(/Couldn't find Todo/)
    end
  end

  describe "when a record is invalid" do
    it "returns status 422 with the validation errors" do
      post :create

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["message"]).to match(/Title can't be blank/)
    end
  end
end
