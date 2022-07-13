class CoversController < ApplicationController
  include ActiveStorage::SetCurrent

  ADMINABLE_CONTROLLER_ACTIONS = [
    :archive,
    :archive_all,
    :index,
    :update_order
  ]

  before_action :authenticate_user!, only: ADMINABLE_CONTROLLER_ACTIONS
  before_action :kick_normals, only: ADMINABLE_CONTROLLER_ACTIONS

  def artwork
    cover = Cover.find(params[:id])

    redirect_to admin_path unless cover.artwork.attached?

    @artwork =
      if cover.artwork.variable?
        cover.artwork.variant(resize_to_limit: [1440,1440]).processed.url
      else
        rails_blob_path(cover.artwork, disposition: "inline")
      end
  end

  def new
    @cover = Cover.new
  end

  def create
    cover = Cover.new(new_cover_params)
    if cover.save
      flash[:notice] = "Successfully submitted %s – \"%s\"." % [
        cover.artist_name,
        cover.song_title
      ]
      redirect_to "/success"
    else
      flash[:error] = "ERROR: There was a problem saving your cover."
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
    redirect_to admin_path
  end

  def unarchive
    Cover.find(params[:id]).undiscard!
    redirect_back fallback_location: admin_archived_path(password: params[:password])
  end

  def archive_all
    covers =
      if params[:ids].blank?
        params[:b_sides] ? Cover.b_sides : Cover.no_b_sides
      else
        Cover.where id: params[:ids].split(",")
      end

    covers.update_all(discarded_at: Time.current)
    redirect_to admin_path
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

  def kick_normals
    if ADMINABLE_CONTROLLER_ACTIONS.include? action_name.to_sym
      redirect_to new_user_session_path unless current_user.admin?
    else
      redirect_to "/", alert: "Admins only, sorry!"
    end
  end

  def new_cover_params
    params.require(:cover).permit(
      :artist_name,
      :artwork,
      :b_side,
      :blurb,
      :file,
      :pronouns,
      :song_title,
      :start_time
    )
  end
end
