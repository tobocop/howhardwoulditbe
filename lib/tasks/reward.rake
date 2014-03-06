namespace :reward do
  desc 'Sends out reward notifications to users who have earned Plink Points'
  task send_reward_notifications: :environment do
    begin
      award_records = Plink::AwardRecord.select('distinct userID').
        plink_point_awards_pending_notification

      award_records.each do |award_record|
        send_reward_notification(award_record)
      end
    rescue Exception
      ::Exceptional::Catcher.handle($!, "send_reward_notifications Rake task failed")
    end
  end

  desc 'One time task to add new tango rewards'
  task add_new_tango_rewards: :environment do
    Plink::RewardRecord.create(
      award_code: 'flowers-gift-card',
      description: "Gift-giving has never been easier with the 1-800-FLOWERS.COM&reg; Gift Card! Browse a wide selection of fresh flowers, delicious gourmet treats and desserts, beautiful plants, stunning gift baskets and more – and then choose exactly what you want!",
      name: "1-800-FLOWERS.COM&reg; Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/1800Flowers.png',
      terms: "1-800-FLOWERS.COM is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions.   Your Gift Card is redeemable at 1-800-FLOWERS.COM&reg;, 1-800-BASKETS.COM&reg;, Fannie May&reg;, Cheryl's&reg; and The Popcorn Factory&reg;--online, by phone where available, and at certain participating stores.  Please allow 7 days from purchase date for UPS Ground delivery.  No expiration date and no service fee!   This offer cannot be combined with Promotion Codes.",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'barnes-gift-card',
      description: "The Barnes &amp; Noble eGift Card can be redeemed at any Barnes &amp; Noble store and online at BN.com (www.bn.com) – where you'll find an amazing selection of books, NOOK Books&trade;, (eBooks), CDs, DVDs, toys, games, and more. It can also be redeemed for NOOK eReader devices.",
      name: "Barnes &amp; Noble eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/barnesandnoble.png',
      terms: "* Barnes &amp; Noble is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. A Barnes &amp; Noble eGift Card may be used to purchase annual memberships in the Barnes &amp; Noble Membership program (continuous billing memberships require a valid credit card). Dormancy fees do not apply to balances on Barnes &amp; Noble eGift Cards. The Barnes &amp; Noble eGift Card will not be exchangeable for cash, except where required by law. Barnes &amp; Noble will not be responsible for lost or stolen Barnes &amp; Noble eGift Cards. If you have any additional Barnes &amp; Noble eGift Card questions, get Barnes &amp; Noble eGift Card Help at http://www.barnesandnoble.com/gc/gc_about_card.asp?cds2Pid=17599&linkid=1035340.",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 50, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'home-gift-card',
      description: "The Home Depot&reg; is the world's largest home improvement specialty retailer and they have something for everybody, from the novice painter to the gardening master.  With The Home Depot&reg; eGift Card you can shop at more than 2,200 retail locations throughout the U.S., Canada, and Mexico and online at www.homedepot.com.  The Home Depot&reg; – revolutionizing the home improvement industry by bringing the know-how and the tools to the consumer. More saving.",
      name: "The Home Depot&reg; eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/HomeDepot.png',
      terms: "* Plink is not affiliated with The Home Depot&reg;. The Home Depot&reg; is not a sponsor of this promotion. The Home Depot&reg; is a registered trademark of Homer TLC, Inc. Valid toward purchase of merchandise/services at any The Home Depot&reg; store in the U.S., Canada and online at HomeDepot.com. Gift Card carries no implied warranties and is not a credit/debit card. Not redeemable for cash (unless required by law) and cannot be applied to any credit or loan balance, Tool Rental deposits, or for in-home/phone purchases.  Gift Cards will not be cancelled and replaced without proof of purchase. Except as required by law, Gift Cards purchased with cash will not be replaced and any Gift Card may be deactivated or rejected in connection with fraudulent actions. Check your balance at any The Home Depot store or online. Reload card value at any The Home Depot store.  &copy; 2013. HOMER TLC, Inc. All rights reserved.  Redeemable in local funds at Home Depot's then applicable exchange rate.",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'starbucks-gift-card',
      description: "A Starbucks Card can bring a little goodness into everyone's day. Whether you use it for  your favorite flavored ice tea or give one to a friend who loves her morning mocha, it's a great way for you or a loved one to enjoy a slice of happiness.",
      name: "Starbucks eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Starbucks.png',
      terms: "The Starbucks word mark and the Starbucks Logo are trademarks of Starbucks Corporation. Starbucks is also the owner of the Copyrights in the Starbucks Logo and the Starbucks Card designs. All rights reserved. Starbucks is not a participating partner or sponsor in this offer. Reload your eGift and check your balance at participating Starbucks stores, www.starbucks.com/card or 1-800-782-7282. Your Starbucks Card eGift may only be used for making purchases at participating Starbucks stores. It cannot be redeemed for cash unless required by law. Refunds can only be provided for unused eGifts with the original receipt. This eGift does not expire, nor does Starbucks charge fees. Complete terms and conditions available on our website. Use of this eGift constitutes acceptance of these terms and conditions. Treat this eGift like Cash. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 50, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'target-gift-card',
      description: "A Target eGiftCard is your opportunity to shop for thousands of items at more than 1,700 Target and SuperTarget&reg; stores in the U.S., as well as Target.com. From home decor, small appliances and electronics to fashion, accessories and music, find exactly what you're looking for at Target. No fees. No expiration. No kidding.&reg;",
      name: "Target eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Target.png',
      terms: "The Bullseye Design, Target and Target GiftCards are registered trademarks of Target Brands Inc. Terms and conditions are applied to gift cards. Target is not a participating partner in or sponsor of this offer.",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'staples-gift-card',
      description: "Giving the perfect gift has never been easier! Whatever the season or reason, a Staples gift card makes a great gift. With thousands of options, there's something for everyone — digital cameras, GPS, laptops, printers and more!",
      name: "Staples Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Staples.png',
      terms: "*Staples is not a sponsor of the rewards or promotion or otherwise affiliated with [company name]. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates. &copy; 2013 Staples International, Inc. The Staples logo is a registered trademark and copyrighted work of Staples International, Inc. PROTECT THIS CARD LIKE CASH! Instructions: This card may be used just like cash toward the purchase of merchandise and services at any Staples U.S. retail store; your receipt will show the remaining balance on the card. For balance, or if you have questions, call 1-888-609-6963 or visit staples.com/giftcards. Value can be added to this card at any Staples U.S. retail store. Terms and Conditions: Valid only if purchased from a Staples U.S. retail store, at staples.com&reg; or from an authorized reseller or distributor, or received from an authorized distributor; Staples reserves the right to not honor cards obtained from unauthorized sellers, including Internet auction sites. Card has no value until activated. Lost, stolen or damaged cards replaced only with valid proof of purchase to extent of remaining card balance. May be used only in Staples U.S. retail stores. Cannot be used for credit card payments or to purchase other gift cards (including Staples Gift Cards) or wireless cards. Not redeemable for cash or credit except where required by law. No more than five cards may be used for any single purchase. Cards may not be consolidated. Card issued by Staples Value, LLC. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true)
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'sears-gift-card',
      description: "The Sears Gift Card offers endless smiles and amazing possibilities.  With no expiration, get the brands and products you want at Sears, Kmart, and Lands' End, both online and in store when you want.  It's the perfect card for home, apparel, jewelry, electronics, automotive, lawn &amp; garden and much more.",
      name: "Sears Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Sears.png',
      terms: "* Sears is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. This card is issued by SHC Promotions LLC and is redeemable for goods and services at participating Sears, Roebuck and Co., Lands' End, The Great Indoors, and Kmart store locations in the U.S., P.R., Guam and U.S.V.I., and at sears.com, kmart.com, landsend.com and Lands' End catalogs. Not valid for purchase of third party debit or prepaid cards. Not redeemable for restaurant, Olan Mills Portrait Studio transactions or for cash, except where required by law. Cannot be applied to credit accounts. Lost, stolen or damaged gift cards may only be cancelled and replaced with proof of purchase. &copy; 2013 SHC Promotions LLC. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'papa-gift-card',
      description: "Papa John's has a gift card that really delivers, because we're committed to quality. We use only the finest ingredients, from fresh-sliced vegetables to our fresh, never-frozen, hand-tossed dough. It's quality that you can taste. We believe that Better Ingredients make a Better Tasting Pizza. Gift card is redeemable by phone, in restaurants and online. There are more than 2,800 restaurants in the U.S., including Alaska and Hawaii. No expiration date and no service fees.",
      name: "Papa John's Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/PapaJohns.png',
      terms: "* Papa John's is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. Redeemable for the purchase of food, beverage, and gratuity at participating Papa John's. Verification may be required if the card is used other than by physical presentation (such as telephone ordering or online ordering). If the card is lost, stolen, damaged or destroyed, it will not be replaced or replenished and you will lose any remaining value on the card. To inquire about the card balance, call 1-800-325-1119. For a location near you visit their website at www.papajohns.com. Please treat this eGift Card like cash and safeguard it accordingly.",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'kmart-gift-card',
      description: "Kmart offers a wide selection of top quality merchandise from well-known labels as Jaclyn Smith, Joe Boxer, and Martha Stewart at exceptional prices.",
      name: "Kmart Digital Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Kmart.png',
      terms: "*Kmart is not a sponsor of the rewards or promotion or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. This card is issued by SHC Promotions, LLC and is redeemable for merchandise and services purchased in conjunction with merchandise at participating Kmart, Sears, Lands' End, and The Great Indoors store locations, except restaurant or Portrait Studio transactions, in the U.S., Puerto Rico, Guam and the U.S. Virgin Islands, and at kmart.com, sears.com, landsend.com and Lands' End consumer catalogs. It cannot be redeemed for cash or applied to your Kmart, Sears, Lands' End, or The Great Indoors credit accounts, except where required by law. Lost, stolen or damaged gift cards may only be cancelled and replaced with the required proof of purchase. &copy; Kmart Corporation. For your balance inquiry call 1-800-922-5511. Visit our website at www.kmart.com. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'dominos-gift-card',
      description: "Domino's is more than pizza! Try one of three varieties of stuffed cheesy bread, a delicious variety of Domino's Artisan&trade;  specialty pizzas, Oven Baked Sandwiches, Parmesan Bread Bites, or Chocolate Lava Crunch Cakes. Order online at www.dominos.com for lunch, dinner, or your next occasion.",
      name: "Domino's Pizza eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/Dominos.png',
      terms: "Participation by Domino's Pizza in the program is not intended as, and shall not constitute, a promotion or marketing of the program by Domino's Pizza. Prices, participation, delivery area and charges may vary, including AK and HI. Returned checks, along with the state's maximum allowable returned check fee, may be electronically presented to your bank. &copy;2013 Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC Usable up to balance only to buy goods or services at participating Domino's Pizza stores in the U.S. Not redeemable to purchase gift cards. Not redeemable for cash except as required by law. Not a credit or debit card. Safeguard the card. It will not be replaced or replenished if lost, stolen or used without authorization. CARDCO CXXV, Inc. is the card issuer and sole obligor to card owner. CARDCO may delegate its issuer obligations to an assignee, without recourse. If delegated, the assignee, and not CARDCO, will be sole obligor to card owner. Resale by any unlicensed vendor or through any unauthorized channels such as online auctions is prohibited. Purchase, use or acceptance of card constitutes acceptance of these terms. For balance inquiries go to www.dominos.com or call 877-250-2278 and for other inquiries visit www.dominos.com. Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'bk-gift-card',
      description: "The original HOME OF THE WHOPPER&reg;, our commitment to premium ingredients, signature recipes, and family-friendly dining experiences is what has defined our brand for more than 50 successful years.",
      name: "BK&reg; eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/BurgerKing.png',
      terms: "*BURGER KING&reg; is not a sponsor of the rewards or promotion or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates. Prices, participation, delivery area and charges may vary, including AK and HI. Returned checks, along with the state's maximum allowable returned check fee, may be electronically presented to your bank. &copy;2013 Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC When you buy or receive a BK&reg; eGift, the following additional terms and conditions shall apply. A BK&reg; eGift is an electronic version of the BK Crown Card that may be purchased online where available or received and/or awarded as a prize in connection with certain BKC online and social media promotional activities. BK&reg; eGifts are not re-loadable and are delivered to the recipient in the form of a sixteen (16) digit code via e-mail or on the recipient's designated social media web page, including a Facebook page. BK&reg; eGifts can only be redeemed by presenting the sixteen (16) digit code at Participating Restaurants by showing a crew member the code on your smartphone or in printed format. The value of your BK&reg; eGift, monetary or otherwise, will not be replaced by BKC if your BK&reg; eGift is lost, stolen or damaged. You should protect your BK&reg; eGift account number. If you share your account number, others may redeem the gift resulting in a depletion or total loss of the value of your BK&reg; eGift ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 15, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
      ]
    )

    Plink::RewardRecord.create(
      award_code: 'bestbuy-gift-card',
      description: "Best Buy is the global leader in consumer electronics, offering the latest devices and services all in one place. And at BestBuy.com, you can shop when and where you want.",
      name: "Best Buy eGift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/BestBuy.png',
      terms: "* Best Buy is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions.  All U.S. Gift Cards are redeemable in any U.S. and Puerto Rico Best Buy retail locations, or online at BestBuy.com where available, for merchandise or services including Geek Squad services.  No expiration date; no fees Not redeemable for cash. Lost, stolen or damaged cards replaced only with valid proof of purchase to the extent of remaining card balance. Not a credit or debit card. Not valid as payment on a Best Buy credit card. Check Gift Card balance at any U.S. and Puerto Rico Best Buy retail locations, online at BestBuy.com or call 1-888-716-7994 with Gift Card number. Receipt will show remaining Gift Card balance. Physical Gift Cards may be reloaded at any U.S. and Puerto Rico Best Buy retail locations. All terms enforced except where prohibited by law. Purchases of a physical Gift Card in any Best Buy retail location or online at Bestbuy.com are eligible for Reward Zone points, excluding Best Buy for Business or commercial purchases of Gift Cards. ",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 5, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 10, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
      ]
    )
  end

private

  def get_reward(award_record)
    if award_record.free_award_id
      Plink::FreeAwardRecord.find(award_record.free_award_id)
    elsif award_record.qualifying_award_id
      Plink::QualifyingAwardRecord.find(award_record.qualifying_award_id)
    elsif award_record.non_qualifying_award_id
      Plink::NonQualifyingAwardRecord.find(award_record.non_qualifying_award_id)
    end
  end

  def default_virtual_currency_presenter
    @virtual_currency ||= VirtualCurrencyPresenter.new(virtual_currency: Plink::VirtualCurrency.default)
  end

  def create_reward_open_structs(award_records)
    award_records.map do |award_record|
      OpenStruct.new(
        award_display_name: award_record.award_display_name,
        currency_award_amount: default_virtual_currency_presenter.amount_in_currency(award_record.dollar_award_amount)
      )
    end
  end

  def send_reward_notification(award_record)
    begin
      user = Plink::UserService.new.find_by_id(award_record.user_id)
      user_rewards = Plink::AwardRecord.where('userID = ?', user.id).
        plink_point_awards_pending_notification.all

      rewards = create_reward_open_structs(user_rewards)
      user_token = AutoLoginService.generate_token(user.id)
      RewardMailer.delay.reward_notification_email(
        email: user.email,
        rewards: rewards,
        user_currency_balance: default_virtual_currency_presenter.amount_in_currency(user.current_balance),
        user_token: user_token
      )

      user_rewards.each do |users_reward|
        reward = get_reward(users_reward)
        reward.update_attributes(is_notification_successful: true)
      end
    rescue Exception
      message = "send_reward_notifications failure for user.id = #{award_record.user_id}"
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end
end
