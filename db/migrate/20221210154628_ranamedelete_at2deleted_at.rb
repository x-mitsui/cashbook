class RanamedeleteAt2deletedAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :tags, :delete_at, :deleted_at
  end
end
