class User < ApplicationRecord
  # 分号紧挨email
  validates :email, presence: true
end
