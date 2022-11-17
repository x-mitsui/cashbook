class CreateUsers < ActiveRecord::Migration[7.0] # 小于号是继承，7.0是版本号
  def change # 实现change方法
    create_table :users do |t| # 创建表users，为其添加两个字段
      t.string :email
      t.string :name, limits: 100 # 可以限制长度

      t.timestamps # 创建created_at、updated_at
    end
  end
end
