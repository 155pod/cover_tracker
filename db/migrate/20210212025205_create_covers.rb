class CreateCovers < ActiveRecord::Migration[6.1]
  def change
    create_table :covers do |t|
      t.string :artist_name
      t.string :pronouns
      t.string :song_title
      t.text :blurb

      t.timestamps
    end
  end
end
