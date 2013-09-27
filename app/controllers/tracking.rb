module Tracking
  def track_email_capture_event(user_id)
    plink_event_service.create_email_capture(user_id, tracking_params.to_hash)
  end

  def track_registration_start_event
    plink_event_service.create_registration_start(tracking_params.to_hash)
  end

  def update_registration_start_event(user_id)
    if get_registration_start_event_id.present?
      plink_event_service.update_event_user_id(get_registration_start_event_id, user_id)
    end
  end

  def steelhouse_additional_info
    tracking_params.steelhouse_additional_info(current_virtual_currency.id)
  end

  def contest_tracking_params(contest_id)
    tracking_object(session_params.merge(sub_id_two: "contest_id_#{contest_id}")).to_hash
  end

  def store_registration_start_event_id(event_id)
    session[:registration_start_event_id] = event_id
  end

  def get_registration_start_event_id
    session[:registration_start_event_id]
  end

  private

  def plink_event_service
    Plink::EventService.new
  end

  def tracking_params
    tracking_object(session_params)
  end

  def session_params
    session[:tracking_params] || {}
  end

  def tracking_object(options)
    TrackingObject.new(options.merge(ip: request.remote_ip))
  end
end
