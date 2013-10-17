class SharePagesController < ApplicationController
  def show
    @affiliate_id = Rails.application.config.default_contest_affiliate_id
    @share_page = Plink::SharePageRecord.find(params[:id])
    @user = current_user
  end

  def create_share_tracking_record
    share_page_tracking = first_or_create(params[:id])

    if !share_page_tracking.persisted? && Rails.env.production?
      msg = "share_pags#create_share_tracking_record failed for user_id: #{current_user.id}, errors #{share_page_tracking.errors.full_messages.join(', ')}"
      ::Exceptional::Catcher.handle(Exception.new(msg))
    end

    render nothing: true
  end

  def update_share_tracking_record
    share_page_tracking = first_or_create(params[:id])
    shared = params[:shared] == 'true' ? true : false

    if !share_page_tracking.update_attributes(shared: shared) && Rails.env.production?
      msg = "share_pags#update_share_tracking_record failed for user_id: #{current_user.id}, errors #{share_page_tracking.errors.full_messages.join(', ')}"
      ::Exceptional::Catcher.handle(Exception.new(msg))
    end

    render nothing: true
  end

private

  def first_or_create(share_page_id)
    Plink::SharePageTrackingRecord.where(
      registration_link_id: session[:registration_link_id],
      share_page_id: share_page_id,
      user_id: current_user.id
    ).first_or_create
  end
end
