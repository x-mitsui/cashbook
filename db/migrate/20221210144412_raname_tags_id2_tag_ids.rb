class RanameTagsId2TagIds < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :tags_id, :tag_ids
  end
end
