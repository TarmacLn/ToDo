# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Todos API V1',
        version: 'v1',
        description: <<~DESC
          REST API for todo lists and their items, with JWT authentication.

          **How to use it**
          1. Create an account with `POST /signup`, or log in with `POST /auth/login`.
          2. Copy the `auth_token` from the response.
          3. Click **Authorize** and paste the token. Every other endpoint needs it.
          4. `GET /auth/logout` revokes the token, so it can no longer be used.

          Tokens expire after 24 hours. Each user only sees their own todos;
          another user's todo returns 404.
        DESC
      },
      servers: [
        { url: 'http://localhost:3000' }
      ],
      tags: [
        { name: 'Authentication', description: 'Sign up, log in and log out' },
        { name: 'Todos', description: 'Todo lists of the logged-in user' },
        { name: 'Items', description: 'Items inside a todo list' }
      ],
      # Every endpoint needs a token unless it says otherwise
      security: [ { bearer_auth: [] } ],
      paths: {},
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          error: {
            type: :object,
            properties: {
              message: { type: :string, example: "Couldn't find Todo with 'id'=0" }
            },
            required: %w[message]
          },
          message: {
            type: :object,
            properties: {
              message: { type: :string }
            },
            required: %w[message]
          },
          auth_token: {
            type: :object,
            properties: {
              auth_token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
            },
            required: %w[auth_token]
          },
          signup_response: {
            type: :object,
            properties: {
              message: { type: :string, example: 'Account created successfully' },
              auth_token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
            },
            required: %w[message auth_token]
          },
          item: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Buy milk' },
              done: { type: :boolean, example: false },
              todo_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name done todo_id created_at updated_at]
          },
          todo: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              title: { type: :string, example: 'Groceries' },
              user_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id title user_id created_at updated_at]
          },
          todo_with_items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              title: { type: :string, example: 'Groceries' },
              user_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' },
              items: { type: :array, items: { '$ref' => '#/components/schemas/item' } }
            },
            required: %w[id title user_id created_at updated_at items]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml

  # Start ids at 1 in every doc spec, so the examples in the docs read nicely
  config.before(file_path: %r{spec/integration}) do
    %w[users todos items jwt_denylists].each do |table|
      ActiveRecord::Base.connection.reset_pk_sequence!(table)
    end
  end

  # Save the real response of each documented test as an example in the docs
  config.after do |example|
    next unless example.metadata[:response] && response.body.present?

    example.metadata[:response][:content] = {
      'application/json' => {
        example: JSON.parse(response.body, symbolize_names: true)
      }
    }
  end
end
