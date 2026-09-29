require "rails_helper"

RSpec.describe Todo, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:items).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end
end
