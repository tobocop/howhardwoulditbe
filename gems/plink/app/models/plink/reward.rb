module Plink
  class Reward

    attr_reader :name, :amounts, :description, :logo_url

    def initialize(attributes, amount_records)
      @name = attributes.fetch(:name)
      @description = attributes.fetch(:description)
      @logo_url = attributes.fetch(:logo_url)
      @amounts = award_amounts(amount_records)
    end

    private

    def award_amounts(amount_records)
      amount_records.map {|amount_record| Plink::RewardAmount.new(amount_record)}
    end
  end
end