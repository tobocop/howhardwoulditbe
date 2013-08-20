namespace :memolink do
  desc 'One-time task to convert memolink to not having a wallet' 
  task convert_to_all_offers: :environment do
    memolink_virtual_currency = Plink::VirtualCurrency.find_by_sudomain('memolink').first
    memolink_virtual_currency.update_attributes(has_all_offers: true)

    offers_virtual_currencies = Plink::OffersVirtualCurrencyRecord.for_currency_id_with_active_offers(memolink_virtual_currency.id)
    offers_virtual_currencies.each do |offers_virtual_currency|

      offers_virtual_currency.live_tiers.each do |tier|
        tier.update_attributes(end_date: 1.day.ago)
      end

      next if offers_virtual_currency.active_offer.nil?

      rev_share = offers_virtual_currency.active_offer.advertisers_rev_share 
      percent_award_amount = (((rev_share.to_f * 0.75) * 0.4) * 100).round(1)

      Plink::TierRecord.create(start_date: 1.day.ago,
        end_date: '2999-12-31',
        dollar_award_amount: 0,
        minimum_purchase_amount: 0.01,
        offers_virtual_currency_id: offers_virtual_currency.id,
        percent_award_amount: percent_award_amount
      )
    end
  end
end
