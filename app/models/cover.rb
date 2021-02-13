class Cover < ApplicationRecord
  has_one_attached :file
  has_one_attached :artwork

  validates :song_title, presence: true
  validates :artist_name, presence: true
  validates :file, presence: true
end
