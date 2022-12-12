class Tag < ApplicationRecord
  paginates_per 25
  enum kind: { expenses: 1, income: 2 }
  validates :name, presence: true
  validates :name, length: { maximum: 4 }
  validates :sign, presence: true
  validates :kind, presence: true
  # tag属于user
  belongs_to :user
  # 保证每次取到的tag都是deleted_at为nil的
  def self.default_scope
    where(deleted_at: nil)
  end
end
