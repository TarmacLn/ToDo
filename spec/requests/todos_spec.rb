require "rails_helper"

RSpec.describe "Todos", type: :request do
  let(:user) { create(:user) }
  let!(:todos) { create_list(:todo, 5, user: user) }
  let(:todo_id) { todos.first.id }
  let(:headers) { valid_headers }

  describe "GET /todos" do
    before do
      create(:item, todo: todos.first)
      create(:todo) # belongs to another user
      get "/todos", headers: headers
    end

    it "returns only the current user's todos" do
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(5)
      expect(json.map { |todo| todo["user_id"] }.uniq).to eq([ user.id ])
    end

    it "includes the items of each todo" do
      first = json.find { |todo| todo["id"] == todo_id }
      expect(first["items"].size).to eq(1)
    end
  end

  describe "GET /todos/:id" do
    before { get "/todos/#{todo_id}", headers: headers }

    context "when the todo exists" do
      it "returns the todo with its items" do
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(todo_id)
        expect(json["items"]).to eq([])
      end
    end

    context "when the todo does not exist" do
      let(:todo_id) { 0 }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
        expect(json["message"]).to match(/Couldn't find Todo/)
      end
    end

    context "when the todo belongs to another user" do
      let(:todo_id) { create(:todo).id }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /todos" do
    before { post "/todos", params: attributes.to_json, headers: headers }

    context "when the request is valid" do
      let(:attributes) { { title: "Learn Rails" } }

      it "creates a todo for the current user" do
        expect(response).to have_http_status(:created)
        expect(json["title"]).to eq("Learn Rails")
        expect(json["user_id"]).to eq(user.id)
      end
    end

    context "when the title is missing" do
      let(:attributes) { { title: "" } }

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to match(/Title can't be blank/)
      end
    end
  end

  describe "PUT /todos/:id" do
    before { put "/todos/#{todo_id}", params: attributes.to_json, headers: headers }

    context "when the request is valid" do
      let(:attributes) { { title: "Shopping" } }

      it "updates the todo and returns status 204" do
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
        expect(Todo.find(todo_id).title).to eq("Shopping")
      end
    end

    context "when the title is blank" do
      let(:attributes) { { title: "" } }

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /todos/:id" do
    before do
      create_list(:item, 2, todo: todos.first)
      delete "/todos/#{todo_id}", headers: headers
    end

    it "deletes the todo and its items and returns status 204" do
      expect(response).to have_http_status(:no_content)
      expect(Todo.exists?(todo_id)).to be(false)
      expect(Item.where(todo_id: todo_id)).to be_empty
    end
  end

  context "without a token" do
    let(:headers) { invalid_headers }

    before { get "/todos", headers: headers }

    it "returns status 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
