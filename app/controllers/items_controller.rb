class ItemsController < ApplicationController
  before_action :set_todo
  before_action :set_item, only: %i[show update destroy]

  # GET /todos/:todo_id/items
  def index
    json_response(@todo.items.order(:id))
  end

  # POST /todos/:todo_id/items
  def create
    item = @todo.items.create!(item_params)
    json_response(item, :created)
  end

  # GET /todos/:todo_id/items/:id
  def show
    json_response(@item)
  end

  # PUT /todos/:todo_id/items/:id
  def update
    @item.update!(item_params)
    head :no_content
  end

  # DELETE /todos/:todo_id/items/:id
  def destroy
    @item.destroy!
    head :no_content
  end

  private

  def item_params
    params.permit(:name, :done)
  end

  # Only look in the current user's todos, so other users' todos return 404
  def set_todo
    @todo = current_user.todos.find(params[:todo_id])
  end

  # Only look in this todo's items
  def set_item
    @item = @todo.items.find(params[:id])
  end
end
