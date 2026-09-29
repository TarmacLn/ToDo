require "rails_helper"

RSpec.describe Item, type: :model do
  describe "associations" do
    it { should belong_to(:todo) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should allow_values(true, false).for(:done) }
    it { should_not allow_value(nil).for(:done) }
  end

  describe "defaults" do
    it "is not done when created" do
      expect(Item.new.done).to be(false)
    end
  end
end
