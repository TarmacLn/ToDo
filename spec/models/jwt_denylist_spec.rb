require "rails_helper"

RSpec.describe JwtDenylist, type: :model do
  subject { build(:jwt_denylist) }

  describe "validations" do
    it { should validate_presence_of(:jti) }
    it { should validate_presence_of(:exp) }
    it { should validate_uniqueness_of(:jti) }
  end
end
