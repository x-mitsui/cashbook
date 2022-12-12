class Item < ApplicationRecord
  paginates_per 25
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :amount, numericality: { other_than: 0 }
  validates :kind, presence: true
  validates :happened_at, presence: true
  validates :tag_ids, presence: true
  # validates :user_id, presence: true # 校验上保证了不为空

  belongs_to :user # 兼顾校验user_id不为空，所以上面的可注释掉

  validate :check_tag_ids_belong_to_user # 自定义的校验validate不加s，用以区分常规教验

  def check_tag_ids_belong_to_user
    all_tag_ids = Tag.where(user_id: self.user_id).map(&:id) # map获取每一个user的id属性
    # ruby中[1,2]==[1,2]是true的
    # arr1 & arr2 == arr2 那么 arr1包含arr2，&符号取交集
    if self.tag_ids & all_tag_ids != self.tag_ids
      self.errors.add :tag_ids, "不属于当前用户"
    end
  end

  def tags
    Tag.where(id: tag_ids)
  end

  # 删除的item也不再显示
  def self.default_scope
    where(deleted_at: nil)
  end
end
