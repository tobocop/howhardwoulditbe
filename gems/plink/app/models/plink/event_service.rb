module Plink
  class EventService

    def self.get_card_add_event(user_id)
      card_add_event_type_record = get_event_type_record(Plink::EventTypeRecord.card_add_type)
      get_event_by_user_id_and_type(user_id, card_add_event_type_record.id)
    end

    def self.get_email_capture_event(user_id)
      email_capture_event_type_record = get_event_type_record(Plink::EventTypeRecord.email_capture_type)
      get_event_by_user_id_and_type(user_id, email_capture_event_type_record.id)
    end

    def create_registration_start(tracking_params = {})
      event_type = get_event_type(registration_start_event_type)
      create_event(0, event_type.id, tracking_params)
    end

    def create_email_capture(user_id, tracking_params = {})
      #TODO: this is for legacy code that should be removed with #57665410
       if tracking_params[:campaign_id].nil? && tracking_params[:campaign_hash].present?
         tracking_params[:campaign_id] = get_campaign_id(tracking_params[:campaign_hash])
       end

      event_type = get_event_type(email_event_type)
      create_event(user_id, event_type.id, tracking_params)
    end

    def create_institution_authenticated(user_id, tracking_params = {})
      event_type = get_event_type(institution_authenticated_event_type)
      create_event(user_id, event_type.id, tracking_params)
    end

    def get_campaign_id(campaign_hash)
      campaign = Plink::CampaignRecord.for_campaign_hash(campaign_hash)
      campaign ? campaign.id : nil
    end

    def update_event_user_id(event_id, user_id)
      event = Plink::EventRecord.find(event_id)
      event.update_attribute(:user_id, user_id)
    end

  private

    def self.get_event_type_record(type)
      Plink::EventTypeRecord.where(name: type).first
    end

    def self.get_event_by_user_id_and_type(user_id, event_type_id)
      Plink::EventRecord.where('userID = ?', user_id)
        .where('eventTypeID = ?', event_type_id)
        .first
    end

    def create_event(user_id, event_type_id, options = {})
      Plink::EventRecord.create(
        user_id: user_id,
        event_type_id: event_type_id,
        affiliate_id: options[:affiliate_id],
        sub_id: options[:sub_id],
        sub_id_two: options[:sub_id_two],
        sub_id_three: options[:sub_id_three],
        sub_id_four: options[:sub_id_four],
        path_id: options[:path_id],
        campaign_id: options[:campaign_id],
        landing_page_id: options[:landing_page_id],
        ip: options[:ip]
      )
    end

    def email_event_type
      Plink::EventTypeRecord.email_capture_type
    end

    def registration_start_event_type
      Plink::EventTypeRecord.registration_start_type
    end

    def institution_authenticated_event_type
      Plink::EventTypeRecord.card_add_type
    end

    def get_event_type(type)
      Plink::EventTypeRecord.for_name(type)
    end
  end
end
