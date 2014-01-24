class ContestReferralsController < ApplicationController
  include TrackingExtensions

  def new
    session[:contest_source] = params[:source]

    set_session_tracking_params(new_tracking_object(trackable_params))

    redirect_to source_is_winning_post? ? contest_path(params[:contest_id]) : contests_path
  end

private

  def source_is_winning_post?
    params[:source] == 'facebook_winning_entry_post'
  end

  def trackable_params
    params.merge(
      referrer_id: params[:user_id],
      sub_id: session[:contest_source],
      sub_id_three: 'contest_id_' + params[:contest_id]
    )
  end
end
