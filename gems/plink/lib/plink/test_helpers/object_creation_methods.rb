module Plink
  module ObjectCreationMethods

    def new_offer(options = {})
      defaults = {
          advertiser_name: 'Gap',
          advertiser_id: 0,
          advertisers_rev_share: 0,
          detail_text: 'awesome text',
          start_date: '1900-01-01'
      }

       Plink::Offer.new(defaults.merge(options))
    end

    def create_offer(options = {})
      offer = new_offer(options)
      offer.save!
      offer
    end
  end
end