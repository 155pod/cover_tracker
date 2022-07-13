class Submission < ApplicationRecord
  self.table_name = "covers"

  has_one_attached :file
  has_one_attached :artwork

  validates :song_title, presence: true
  validates :artist_name, presence: true
  validates :file, presence: true

  include Discard::Model

  scope :b_sides, ->() { where(b_side: true) }
  scope :no_b_sides, ->() { where(b_side: false) }
  scope :display_order, ->() {
    order(position: :asc, created_at: :desc)
  }

  def start_time
    if time = start_time_seconds
      "%i:%.2i" % [(time / 60), time % 60]
    else
      nil
    end
  end

  def start_time=(value)
    if value && value =~ /(\d+):(\d+)/
      self.start_time_seconds = ($1.to_i * 60 + $2.to_i)
    else
      self.start_time_seconds = nil
    end
  end
end
