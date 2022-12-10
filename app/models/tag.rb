class Tag < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :name, presence: true
  validates :sign, presence: true
  # tag属于user
  belongs_to :user
end
