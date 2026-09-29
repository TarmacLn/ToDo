module Response
  # Render any object as JSON with the given HTTP status
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
