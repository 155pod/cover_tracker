class CoversController < ApplicationController
  before_action :password_required, only: [:index, :archive, :archive_all]

  def new
    @cover = Cover.new
  end

  def create
    cover = Cover.new(new_cover_params)
    if cover.save
      flash[:notice] = "Successfully submitted #{cover.artist_name} - \"#{cover.song_title}\""
      redirect_to "/success"
    else
      flash[:error] = "ERROR: There was a problem saving your cover"
      redirect_to "/"
    end
  end

  def success
  end

  # List covers (admin)
  def index
    @covers = Cover.kept.includes(artwork_attachment: :blob, file_attachment: :blob).order(created_at: :desc)
  end

  def archive
    Cover.find(params[:id]).discard!
    redirect_to_admin
  end

  def archive_all
    Cover.update_all(discarded_at: Time.current)
    redirect_to_admin
  end

  private

  def new_cover_params
    params.require(:cover).permit(:song_title, :pronouns, :artist_name, :file, :blurb, :artwork)
  end

  def password_required
    password = params[:password].to_s
    secret = Rails.application.credentials[:password]
    unless ActiveSupport::SecurityUtils.secure_compare(password, secret)
      render plain: "password required", status: 403
    end
  end

  def redirect_to_admin
    redirect_to admin_path(password: params[:password])
  end
end
