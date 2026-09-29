require "swagger_helper"

RSpec.describe "Items API", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{token_generator(user.id)}" }
  let(:todo) { create(:todo, user: user, title: "Groceries") }
  let(:todo_id) { todo.id }

  path "/todos/{todo_id}/items" do
    parameter name: :todo_id, in: :path, type: :integer, description: "Todo id"

    get "List the items of a todo" do
      tags "Items"
      produces "application/json"

      response "200", "Items found" do
        schema type: :array, items: { "$ref" => "#/components/schemas/item" }
        before { create(:item, todo: todo, name: "Buy milk") }

        run_test!
      end

      response "404", "Todo not found" do
        schema "$ref" => "#/components/schemas/error"
        let(:todo_id) { 0 }

        run_test!
      end
    end

    post "Create a todo item" do
      tags "Items"
      description "New items start with done = false."
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Buy milk" },
          done: { type: :boolean, example: false }
        },
        required: %w[name]
      }

      response "201", "Item created" do
        schema "$ref" => "#/components/schemas/item"
        let(:body) { { name: "Buy milk" } }

        run_test!
      end

      response "422", "Name is missing" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { name: "" } }

        run_test!
      end

      response "404", "Todo not found" do
        schema "$ref" => "#/components/schemas/error"
        let(:todo_id) { 0 }
        let(:body) { { name: "Buy milk" } }

        run_test!
      end
    end
  end

  path "/todos/{todo_id}/items/{id}" do
    parameter name: :todo_id, in: :path, type: :integer, description: "Todo id"
    parameter name: :id, in: :path, type: :integer, description: "Item id"

    let(:item) { create(:item, todo: todo, name: "Buy milk") }
    let(:id) { item.id }

    get "Get a todo item" do
      tags "Items"
      produces "application/json"

      response "200", "Item found" do
        schema "$ref" => "#/components/schemas/item"

        run_test!
      end

      response "404", "Item not found in this todo" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }

        run_test!
      end
    end

    put "Update a todo item" do
      tags "Items"
      description "Change the name and/or mark the item as done."
      consumes "application/json"
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Buy oat milk" },
          done: { type: :boolean, example: true }
        }
      }

      response "204", "Item updated" do
        let(:body) { { name: "Buy oat milk", done: true } }

        run_test!
      end

      response "422", "Name is blank" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { name: "" } }

        run_test!
      end

      response "404", "Item not found in this todo" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }
        let(:body) { { done: true } }

        run_test!
      end
    end

    delete "Delete a todo item" do
      tags "Items"

      response "204", "Item deleted" do
        run_test!
      end

      response "404", "Item not found in this todo" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }

        run_test!
      end
    end
  end
end
