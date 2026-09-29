class TodosController < ApplicationController
  before_action :set_todo, only: %i[show update destroy]

  # GET /todos
  def index
    todos = current_user.todos.includes(:items).order(:id)
    json_response(todos.as_json(include: :items))
  end

  # POST /todos
  def create
    todo = current_user.todos.create!(todo_params)
    json_response(todo, :created)
  end

  # GET /todos/:id
  def show
    json_response(@todo.as_json(include: :items))
  end

  # PUT /todos/:id
  def update
    @todo.update!(todo_params)
    head :no_content
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy!
    head :no_content
  end

  private

  def todo_params
    params.permit(:title)
  end

  # Only look in the current user's todos, so other users' todos return 404
  def set_todo
    @todo = current_user.todos.find(params[:id])
  end
end
