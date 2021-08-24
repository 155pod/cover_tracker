class AddBSidesToCovers < ActiveRecord::Migration[6.1]
  def change
    add_column :covers, :b_side, :boolean, default: false, null: false
  end
end
