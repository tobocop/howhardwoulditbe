module Plink
  class OffersVirtualCurrencyRecord < ActiveRecord::Base
    self.table_name = 'offersVirtualCurrencies'

    alias_attribute :is_active, :isActive

    attr_accessible :offer_id, :virtual_currency_id, :detail_text

    has_many :tiers, class_name: 'Plink::TierRecord',
             foreign_key: 'offersVirtualCurrencyID'

    has_many :live_tiers, class_name: 'Plink::TierRecord',
             foreign_key: 'offersVirtualCurrencyID',
             conditions: ["#{Plink::TierRecord.table_name}.isActive = ? AND #{Plink::TierRecord.table_name}.beginDate <= ? AND #{Plink::TierRecord.table_name}.endDate >= ?", true, Date.today, Date.today]

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
