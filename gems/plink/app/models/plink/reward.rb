module Plink
  class Reward

    attr_reader :id, :name, :amounts, :description, :logo_url, :terms

    def initialize(attributes, amount_records)
      @id = attributes.fetch(:id)
      @name = attributes.fetch(:name)
      @description = attributes.fetch(:description)
      @logo_url = attributes.fetch(:logo_url)
      @amounts = award_amounts(amount_records)
      @terms = attributes[:terms]
      @postal_mail_gift_cards = ['Subway Gift Card']
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