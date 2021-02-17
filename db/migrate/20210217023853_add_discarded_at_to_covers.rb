class AddDiscardedAtToCovers < ActiveRecord::Migration[6.1]
  def change
    add_column :covers, :discarded_at, :datetime
    add_index :covers, :discarded_at
  end
end
