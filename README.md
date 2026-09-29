# Todos API

A REST API for todo lists and their items, built with Ruby on Rails.
Users sign up and log in with a JWT token, and each user only sees their own todos.

Built for the course **Υπηρεσιοστρεφές Λογισμικό (Service Oriented Software), 2025-2026**
for the University of Piraeus (Part 2 of the project).

Made by Ioanna Andrianou (TarmacLn)

---

## Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/signup` | Sign up |
| POST | `/auth/login` | Log in |
| GET | `/auth/logout` | Log out |
| GET | `/todos` | List all todos and their items |
| POST | `/todos` | Create a todo |
| GET | `/todos/:id` | Get a todo |
| PUT | `/todos/:id` | Update a todo |
| DELETE | `/todos/:id` | Delete a todo and its items |
| GET | `/todos/:id/items/:iid` | Get a todo item |
| POST | `/todos/:id/items` | Create a todo item |
| PUT | `/todos/:id/items/:iid` | Update a todo item |
| DELETE | `/todos/:id/items/:iid` | Delete a todo item |

All endpoints except signup and login need the token in the `Authorization` header:
`Authorization: Bearer <token>`.

The full documentation (OpenAPI / Swagger) is at <http://localhost:3000/api-docs> while the server runs.

---

## Technologies

- Ruby 3.4.10, Ruby on Rails 8.1 (API-only)
- PostgreSQL
- JWT authentication (`jwt`, `bcrypt`)
- RSpec, FactoryBot, shoulda-matchers, Faker
- rswag for the OpenAPI (Swagger) documentation
- httpie for manual testing

---

## Setup

You need Ruby 3.4.10 and PostgreSQL running.

```bash
git clone https://github.com/TarmacLn/ToDo.git
cd todo
bin/setup
```

`bin/setup` installs the gems, creates the database and starts the server at <http://localhost:3000>.
Later, start the server with:

```bash
bin/rails server
```

---

## Tests

```bash
bundle exec rspec
```

The tests cover the models, the authentication and every endpoint.
The specs in `spec/integration` also generate the Swagger documentation:

```bash
bin/rails docs:generate
```

## Testing with httpie

With the server running, this script calls every endpoint with httpie (including error cases):

```bash
brew install httpie
script/httpie_test.sh
```

The output of a full run is in [`docs/httpie-output.txt`](docs/httpie-output.txt).

### Example

```bash
http POST :3000/signup name=Ioanna email=ioanna@example.com password=password123
http POST :3000/auth/login email=ioanna@example.com password=password123
http -A bearer -a <token> POST :3000/todos title=Groceries
http -A bearer -a <token> POST :3000/todos/1/items name="Buy milk"
http -A bearer -a <token> GET :3000/todos
http -A bearer -a <token> GET :3000/auth/logout
```
