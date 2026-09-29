require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }

    it "rejects an invalid email address" do
      subject.email = "not-an-email"
      expect(subject).not_to be_valid
    end
  end

  describe "email normalization" do
    it "strips spaces and downcases the email" do
      user = create(:user, email: "  Ioanna@Example.COM ")
      expect(user.email).to eq("ioanna@example.com")
    end
  end
end
