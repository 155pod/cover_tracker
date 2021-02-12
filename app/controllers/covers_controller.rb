class CoversController < ApplicationController
  def new
    @cover = Cover.new
  end

  def create
    render plain: "thanks!"
  end

  def show
  end
end
