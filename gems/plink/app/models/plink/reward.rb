module Plink
  class Reward

    attr_reader :amounts, :description, :id, :is_redeemable, :logo_url, :name, :terms

    def initialize(attributes, amount_records)
      @amounts = award_amounts(amount_records)
      @description = attributes.fetch(:description)
      @id = attributes.fetch(:id)
      @is_redeemable = attributes.fetch(:is_redeemable)
      @logo_url = attributes.fetch(:logo_url)
      @name = attributes.fetch(:name)
      @postal_mail_gift_cards = ['Subway Gift Card']
      @terms = attributes[:terms]
    end

    def deliver_by_email?
      !@postal_mail_gift_cards.include?(@name)
    end
    alias_method :deliver_by_email, :deliver_by_email?

    private

    def award_amounts(amount_records)
      amount_records.map { |amount_record| Plink::RewardAmount.new(amount_record) }
    end
  end
end
