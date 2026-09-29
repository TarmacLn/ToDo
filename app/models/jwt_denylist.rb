# Tokens that were logged out. A token whose jti is here is rejected.
class JwtDenylist < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true

  def self.revoked?(jti)
    exists?(jti: jti)
  end
end
