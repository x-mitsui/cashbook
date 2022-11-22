class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :sign
      t.datetime :delete_at

      t.timestamps
    end
  end
end
