class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, limits: 100
      t.string :name, limits: 100

      t.timestamps
    end
  end
end
