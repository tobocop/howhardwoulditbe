module Plink

  class TangoTrackingRecord < ActiveRecord::Base

    self.table_name = 'tangoTracking'

    attr_accessible :user_id, :loot_id, :card_sku, :card_value, :recipient_name, :recipient_email, :sent_to_tango_on,
                    :response_from_tango_on, :response_type, :reference_order_id, :card_token, :card_number, :card_pin

    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'userID'
    belongs_to :loot_record, class_name: 'Plink::LootRecord', foreign_key: 'lootID'

    alias_attribute :tango_tracking_id, :tangoTrackingID
    alias_attribute :user_id, :userID
    alias_attribute :loot_id, :lootID
    alias_attribute :card_sku, :cardSku
    alias_attribute :card_value, :cardValue
    alias_attribute :recipient_name, :recipientName
    alias_attribute :recipient_email, :recipientEmail
    alias_attribute :sent_to_tango_on, :sentToTangoOn
    alias_attribute :response_from_tango_on, :responseFromTangoOn
    alias_attribute :response_type, :responseType
    alias_attribute :reference_order_id, :referenceOrderID
    alias_attribute :card_token, :cardToken
    alias_attribute :card_number, :cardNumber
    alias_attribute :card_pin, :cardPin

  end
end