class AddPositionToCovers < ActiveRecord::Migration[6.1]
  def change
    add_column :covers, :position, :integer, default: 0
  end
end
