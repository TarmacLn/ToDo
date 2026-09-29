require "swagger_helper"

RSpec.describe "Todos API", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{token_generator(user.id)}" }

  todo_body = {
    type: :object,
    properties: {
      title: { type: :string, example: "Groceries" }
    },
    required: %w[title]
  }

  path "/todos" do
    get "List all todos and their items" do
      tags "Todos"
      description "Returns the logged-in user's todos. Each todo includes its items."
      produces "application/json"

      response "200", "Todos found" do
        schema type: :array, items: { "$ref" => "#/components/schemas/todo_with_items" }
        before do
          todo = create(:todo, user: user, title: "Groceries")
          create(:item, todo: todo, name: "Buy milk")
        end

        run_test!
      end

      response "401", "Missing or invalid token" do
        schema "$ref" => "#/components/schemas/error"
        let(:Authorization) { "Bearer invalid-token" }

        run_test!
      end
    end

    post "Create a todo" do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      parameter name: :body, in: :body, schema: todo_body

      response "201", "Todo created" do
        schema "$ref" => "#/components/schemas/todo"
        let(:body) { { title: "Groceries" } }

        run_test!
      end

      response "422", "Title is missing" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { title: "" } }

        run_test!
      end
    end
  end

  path "/todos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Todo id"

    let(:todo) { create(:todo, user: user, title: "Groceries") }
    let(:id) { todo.id }

    get "Get a todo" do
      tags "Todos"
      description "Returns one todo with its items."
      produces "application/json"

      response "200", "Todo found" do
        schema "$ref" => "#/components/schemas/todo_with_items"
        before { create(:item, todo: todo, name: "Buy milk") }

        run_test!
      end

      response "404", "Todo not found, or it belongs to another user" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }

        run_test!
      end
    end

    put "Update a todo" do
      tags "Todos"
      consumes "application/json"
      parameter name: :body, in: :body, schema: todo_body

      response "204", "Todo updated" do
        let(:body) { { title: "Weekly groceries" } }

        run_test!
      end

      response "422", "Title is blank" do
        schema "$ref" => "#/components/schemas/error"
        let(:body) { { title: "" } }

        run_test!
      end

      response "404", "Todo not found" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }
        let(:body) { { title: "Weekly groceries" } }

        run_test!
      end
    end

    delete "Delete a todo and its items" do
      tags "Todos"

      response "204", "Todo and its items deleted" do
        run_test!
      end

      response "404", "Todo not found" do
        schema "$ref" => "#/components/schemas/error"
        let(:id) { 0 }

        run_test!
      end
    end
  end
end
