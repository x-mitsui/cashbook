class User < ApplicationRecord
  validates :email, presence: true

  def generate_jwt
    payload = { user_id: self.id, exp: (Time.now + 2.hours).to_i }
    # 语法：最后一行自动为返回值
    JWT.encode payload, Rails.application.credentials.hmac_secret, "HS256"
  end

  def get_auth_header
    # 语法：最后一行自动为返回值
    { Authorization: "Bearer #{self.generate_jwt}" }
  end
end
