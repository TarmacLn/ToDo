require "rails_helper"

RSpec.describe "Items", type: :request do
  let(:user) { create(:user) }
  let!(:todo) { create(:todo, user: user) }
  let!(:items) { create_list(:item, 3, todo: todo) }
  let(:todo_id) { todo.id }
  let(:id) { items.first.id }
  let(:headers) { valid_headers }

  describe "GET /todos/:todo_id/items" do
    before { get "/todos/#{todo_id}/items", headers: headers }

    context "when the todo exists" do
      it "returns all its items" do
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(3)
      end
    end

    context "when the todo belongs to another user" do
      let(:todo_id) { create(:todo).id }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
        expect(json["message"]).to match(/Couldn't find Todo/)
      end
    end
  end

  describe "GET /todos/:todo_id/items/:id" do
    before { get "/todos/#{todo_id}/items/#{id}", headers: headers }

    context "when the item exists" do
      it "returns the item" do
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(id)
        expect(json["todo_id"]).to eq(todo_id)
      end
    end

    context "when the item does not exist" do
      let(:id) { 0 }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
        expect(json["message"]).to match(/Couldn't find Item/)
      end
    end

    context "when the item belongs to a different todo" do
      let(:id) { create(:item, todo: create(:todo, user: user)).id }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /todos/:todo_id/items" do
    before { post "/todos/#{todo_id}/items", params: attributes.to_json, headers: headers }

    context "when the request is valid" do
      let(:attributes) { { name: "Buy milk" } }

      it "creates an item that is not done" do
        expect(response).to have_http_status(:created)
        expect(json["name"]).to eq("Buy milk")
        expect(json["done"]).to be(false)
        expect(json["todo_id"]).to eq(todo_id)
      end
    end

    context "when the name is missing" do
      let(:attributes) { { done: false } }

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to match(/Name can't be blank/)
      end
    end

    context "when the todo belongs to another user" do
      let(:todo_id) { create(:todo).id }
      let(:attributes) { { name: "Buy milk" } }

      it "returns status 404 and creates nothing" do
        expect(response).to have_http_status(:not_found)
        expect(Item.where(name: "Buy milk")).to be_empty
      end
    end
  end

  describe "PUT /todos/:todo_id/items/:id" do
    before { put "/todos/#{todo_id}/items/#{id}", params: attributes.to_json, headers: headers }

    context "when the request is valid" do
      let(:attributes) { { name: "Buy oat milk", done: true } }

      it "updates the item and returns status 204" do
        expect(response).to have_http_status(:no_content)
        expect(Item.find(id)).to have_attributes(name: "Buy oat milk", done: true)
      end
    end

    context "when the name is blank" do
      let(:attributes) { { name: "" } }

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the item does not exist" do
      let(:id) { 0 }
      let(:attributes) { { name: "Buy oat milk" } }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /todos/:todo_id/items/:id" do
    before { delete "/todos/#{todo_id}/items/#{id}", headers: headers }

    it "deletes only that item and returns status 204" do
      expect(response).to have_http_status(:no_content)
      expect(Item.exists?(id)).to be(false)
      expect(todo.items.count).to eq(2)
    end
  end

  context "without a token" do
    let(:headers) { invalid_headers }

    before { get "/todos/#{todo_id}/items/#{id}", headers: headers }

    it "returns status 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
