class CoversController < ApplicationController
  def new
    @cover = Cover.new
  end

  def create
    cover = Cover.new(cover_params)
    if cover.save
      render plain: "success!"
    else
      render plain: "ERROR!!!"
    end
  end

  def show
  end

  # List covers (admin)
  def index
    @covers = Cover.order(created_at: :desc)
  end

  private

  def cover_params
    params.require(:cover).permit(:song_title, :pronouns, :artist_name, :file, :blurb)
  end
end
