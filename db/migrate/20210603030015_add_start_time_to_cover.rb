class AddStartTimeToCover < ActiveRecord::Migration[6.1]
  def change
    add_column :covers, :start_time_seconds, :integer, default: 0
  end
end
