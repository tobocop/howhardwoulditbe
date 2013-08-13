module Tracking
  def track_email_capture_event(user_id)
    plink_event_service.create_email_capture(user_id, tracking_params.to_hash)
  end

  def steelhouse_additional_info
    tracking_params.steelhouse_additional_info(current_virtual_currency.id)
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
