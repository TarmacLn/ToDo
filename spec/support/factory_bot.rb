RSpec.configure do |config|
  # Use create(:user) instead of FactoryBot.create(:user)
  config.include FactoryBot::Syntax::Methods
end
