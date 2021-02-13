class Cover < ApplicationRecord
  has_one_attached :file
  has_one_attached :artwork
end
