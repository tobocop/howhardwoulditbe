namespace :tier do
  desc 'One-time task to change tiers for 7-Eleven (Plink Points)'
  task update_7_eleven_tiers_20130923: :environment do

    advertiser = Plink::AdvertiserRecord.where('advertiserName = ?', '7 - Eleven').first
    virtual_currency = Plink::VirtualCurrency.default
    offer = Plink::OfferRecord.where('advertiserID = ?', advertiser.id).first
    offers_virtual_currency = Plink::OffersVirtualCurrencyRecord.where(
      'offerID = ? and virtualCurrencyID = ?',
      offer.id,
      virtual_currency.id
    ).first

    ActiveRecord::Base.transaction do
      Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id).each do |tier|
        tier.end_date = Date.today.midnight
        tier.save!
      end

      Plink::TierRecord.new(
        dollar_award_amount: 0.70,
        minimum_purchase_amount: 7,
        start_date: Date.tomorrow.midnight,
        end_date: '2999-12-31 00:00:00.0',
        offers_virtual_currency_id: offers_virtual_currency.id
      ).save!

      Plink::TierRecord.new(
        dollar_award_amount: 1.50,
        minimum_purchase_amount: 20,
        start_date: Date.tomorrow.midnight,
        end_date: '2999-12-31 00:00:00.0',
        offers_virtual_currency_id: offers_virtual_currency.id
      ).save!

    end
  end
end
