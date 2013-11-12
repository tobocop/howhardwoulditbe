module TrackingExtensions
  def new_tracking_object(options = {})
    TrackingObject.new(options.merge(ip: request.remote_ip))
  end

  def new_tracking_object_from_params(attributes = {})
    valid_params = attributes.except(:controller, :action)

    if attributes[:c].present?
      campaign_id = get_campaign_id(attributes[:c])
      valid_params = valid_params.merge('campaign_id' => campaign_id)
    end

    TrackingObject.from_params(valid_params)
  end

  def new_tracking_object_from_session
    new_tracking_object(get_session_tracking_params)
  end

  def set_session_tracking_params(tracking_object)
    session[:tracking_params] = tracking_object.to_hash
  end

  def get_session_tracking_params
    session[:tracking_params] || {}
  end

  def track_email_capture_event(user_id)
    Plink::EventService.new.create_email_capture(user_id, new_tracking_object_from_session.to_hash)
  end

  def track_registration_start_event
    event = Plink::EventService.new.create_registration_start(new_tracking_object_from_session.to_hash)
    session[:registration_start_event_id] = event.id
  end

  def update_registration_start_event(user_id)
    if session[:registration_start_event_id].present?
      Plink::EventService.new.update_event_user_id(session[:registration_start_event_id], user_id)
    end
  end

  def steelhouse_additional_info
    new_tracking_object_from_session.steelhouse_additional_info(current_virtual_currency.id)
  end

  def plink_card_link_url_generator
    Plink::CardLinkUrlGenerator.new(Plink::Config.instance)
  end

private

  def get_campaign_id(campaign_hash)
    Plink::EventService.new.get_campaign_id(campaign_hash)
  end
end