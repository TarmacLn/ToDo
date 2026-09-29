module RequestSpecHelper
  # Parse the JSON response body
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
  config.include RequestSpecHelper, type: :controller
end
