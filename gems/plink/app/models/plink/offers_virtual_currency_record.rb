module Plink
  class OffersVirtualCurrencyRecord < ActiveRecord::Base
    self.table_name = 'offersVirtualCurrencies'

    attr_accessible :offer_id, :virtual_currency_id, :detail_text

    has_many :tiers, class_name: 'Plink::TierRecord', foreign_key: 'offersVirtualCurrencyID'

    def offer_id=(id)
      self.offerID = id
    end

    def virtual_currency_id=(id)
      self.virtualCurrencyID = id
    end

    def detail_text=(text)
      self.detailText = text
    end

    def detail_text
      self.detailText
    end

    def created_at
      self.created
    end

    def updated_at
      self.modified
    end

    private

    def timestamp_attributes_for_create
      super << :created
    end

    def timestamp_attributes_for_update
      super << :modified
    end
  end
end
