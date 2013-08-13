module Plink
  class EventService

    def create_email_capture(user_id, tracking_params = {})
      campaign_id = tracking_params.fetch(:campaign_id, get_campaign_id(tracking_params[:campaign_hash]))
      event_type = get_event_type(email_event_type)

      Plink::EventRecord.create(
        user_id: user_id,
        affiliate_id: tracking_params[:affiliate_id],
        sub_id: tracking_params[:sub_id],
        sub_id_two: tracking_params[:sub_id_two],
        sub_id_three: tracking_params[:sub_id_three],
        sub_id_four: tracking_params[:sub_id_four],
        path_id: tracking_params[:path_id],
        campaign_id: campaign_id,
        event_type_id: event_type.id,
        ip: tracking_params[:ip]
      )
    end

    def get_campaign_id(campaign_hash)
      campaign = Plink::CampaignRecord.for_campaign_hash(campaign_hash)
      campaign ? campaign.id : nil
    end

    private

    def email_event_type
      Plink::EventTypeRecord.email_capture_type
    end

    def get_event_type(type)
      Plink::EventTypeRecord.for_name(type)
    end

  end
end
