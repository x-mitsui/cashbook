require "faker"

FactoryBot.define do
  factory :item do
    user
    amount { Faker::Number.number(digits: 4) } # 生成4位数数字
    tag_ids { [Faker::Number.number(digits: 4)] } # 默认使用随机数字，等外面使用时覆盖个和user有关联的tag_id
    happened_at { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    kind { "expenses" }
  end
end
