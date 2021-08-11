class CoversController < ApplicationController
  before_action :password_required, only: [:index, :archive, :archive_all, :update_order]

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
    @b_sides = Cover.b_sides.kept.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
    @covers = Cover.no_b_sides.kept.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
  end

  def index_archived
    @b_sides = Cover.b_sides.discarded.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
    @covers = Cover.no_b_sides.discarded.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
  end

  def archive
    Cover.find(params[:id]).discard!
    redirect_to_admin
  end

  def unarchive
    Cover.find(params[:id]).undiscard!
    redirect_back fallback_location: admin_archived_path(password: params[:password])
  end

  def archive_all
    Cover.no_b_sides.update_all(discarded_at: Time.current)
    redirect_to_admin
  end

  def archive_b_sides
    Cover.b_sides.update_all(discarded_at: Time.current)
    redirect_to_admin
  end

  def toggle_b_side
    Cover.find(params[:id]).toggle(:b_side).save
    redirect_to request.referrer
  end

  def update_order
    ids = params.require(:ids)
    Cover.transaction do
      ids.each_with_index do |id, index|
        Cover.where(id: id).update_all(position: 1+index)
      end
    end
    head :ok
  end

  private

  def new_cover_params
    params.require(:cover).permit(:song_title, :pronouns, :artist_name, :file, :blurb, :artwork, :start_time, :b_side)
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
