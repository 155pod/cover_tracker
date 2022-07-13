class SubmissionsController < ApplicationController
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
    submission = Submission.find(params[:id])

    redirect_to admin_path unless submission.artwork.attached?

    @artwork =
      if submission.artwork.variable?
        submission.artwork.variant(resize_to_limit: [1440,1440]).processed.url
      else
        rails_blob_path(submission.artwork, disposition: "inline")
      end
  end

  def new
    @submission = Submission.new
  end

  def create
    submission = Submission.new(new_submission_params)
    if submission.save
      flash[:notice] = "Successfully submitted %s – \"%s\"." % [
        submission.artist_name,
        submission.song_title
      ]
      redirect_to "/success"
    else
      flash[:error] = "ERROR: There was a problem saving your submission."
      redirect_to "/"
    end
  end

  def success
  end

  # List submissions (admin)
  def index
    @b_sides = Submission.b_sides.kept.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
    @submissions = Submission.no_b_sides.kept.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
  end

  def index_archived
    @b_sides = Submission.b_sides.discarded.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
    @submissions = Submission.no_b_sides.discarded.includes(artwork_attachment: :blob, file_attachment: :blob).display_order.load
  end

  def archive
    Submission.find(params[:id]).discard!
    redirect_to admin_path
  end

  def unarchive
    Submission.find(params[:id]).undiscard!
    redirect_back fallback_location: admin_archived_path(password: params[:password])
  end

  def archive_all
    submissions =
      if params[:ids].blank?
        params[:b_sides] ? Submission.b_sides : Submission.no_b_sides
      else
        Submission.where id: params[:ids].split(",")
      end

    submissions.update_all(discarded_at: Time.current)
    redirect_to admin_path
  end

  def toggle_b_side
    Submission.find(params[:id]).toggle(:b_side).save
    redirect_to request.referrer
  end

  def update_order
    ids = params.require(:ids)
    Submission.transaction do
      ids.each_with_index do |id, index|
        Submission.where(id: id).update_all(position: 1+index)
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

  def new_submission_params
    params.require(:submission).permit(
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
