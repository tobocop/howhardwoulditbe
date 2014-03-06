require 'spec_helper'

describe 'reward:send_reward_notifications' do
  include_context 'rake'
  let!(:virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:user_with_no_awards) { create_user }
  let!(:user_with_three_awards) { create_user(email: 'spelling@joesspellingacademy.com') }
  let!(:award_type) { create_award_type(email_message: 'for Bananas are awesome') }
  let!(:advertiser) { create_advertiser(advertiser_name: 'angry birds') }
  let(:valid_award_params) {
    {
      user_id: user_with_three_awards.id,
      is_notification_successful: false,
      is_active: true,
      is_successful: true,
      virtual_currency_id: virtual_currency.id
    }
  }
  let!(:free_award) {
    create_free_award(
      valid_award_params.merge(
        award_type_id: award_type.id,
        dollar_award_amount: 1.0
      )
    )
  }
  let!(:qualifying_award) {
    create_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 2.0
      )
    )
  }
  let!(:non_qualifying_award) {
    create_non_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 3.0
      )
    )
  }


  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'send a delayed email to users with an auto login token who have pending rewards' do
      reward_mail = double(deliver: true)
      delay = double(reward_notification_email: reward_mail)

      AutoLoginService.should_receive(:generate_token)
        .with(user_with_three_awards.id)
        .and_return('my_token')

      RewardMailer.should_receive(:delay).and_return(delay)

      delay.should_receive(:reward_notification_email) do |args|
        args[:email].should == 'spelling@joesspellingacademy.com'
        args[:rewards].map(&:award_display_name).should =~ ['Bananas are awesome', 'visiting angry birds', 'visiting angry birds']
        args[:rewards].map(&:currency_award_amount).should =~ ['100', '200', '300']
        args[:user_currency_balance].should == '600'
        args[:user_token].should == 'my_token'
        reward_mail
      end

      subject.invoke
    end

    it 'updates rewards to set is_notification_successful to true that were processed' do
      Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 3

      Plink::FreeAwardRecord.any_instance.should_receive(:update_attributes)
        .with(is_notification_successful: true)
        .and_call_original
      Plink::QualifyingAwardRecord.any_instance.should_receive(:update_attributes)
        .with(is_notification_successful: true)
        .and_call_original
      Plink::NonQualifyingAwardRecord.any_instance.should_receive(:update_attributes)
        .with(is_notification_successful: true)
        .and_call_original

      subject.invoke

      Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 0
    end

    it "gets distinct user id's  with awards pending notification" do
      award_select = double(:plink_point_awards_pending_notification)
      Plink::AwardRecord.should_receive('select').with('distinct userID')
        .and_return(award_select)
      award_select.should_receive(:plink_point_awards_pending_notification)
        .and_return([])

      subject.invoke
    end
  end

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Plink::UserService.stub(:new).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /send_reward_notifications failure for user\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::AwardRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should == 'send_reward_notifications Rake task failed'
      end

      subject.invoke
    end
  end
end

describe 'reward:add_new_tango_rewards' do
  include_context 'rake'

  let(:rewards) { Plink::RewardRecord.all }

  it 'inserts 1-800-Flowers with the correct amounts' do
    subject.invoke

    flowers = rewards[0]
    flowers.amounts.map(&:dollar_award_amount).map(&:to_i).should == [10, 25]
    flowers.award_code.should == 'flowers-gift-card'
    flowers.description.should == "Gift-giving has never been easier with the 1-800-FLOWERS.COM&reg; Gift Card! Browse a wide selection of fresh flowers, delicious gourmet treats and desserts, beautiful plants, stunning gift baskets and more – and then choose exactly what you want!"
    flowers.is_active.should be_true
    flowers.is_redeemable.should be_true
    flowers.is_tango.should be_true
    flowers.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/1800Flowers.png'
    flowers.name.should == "1-800-FLOWERS.COM&reg; Gift Card"
    flowers.terms.should == "1-800-FLOWERS.COM is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions.   Your Gift Card is redeemable at 1-800-FLOWERS.COM&reg;, 1-800-BASKETS.COM&reg;, Fannie May&reg;, Cheryl's&reg; and The Popcorn Factory&reg;--online, by phone where available, and at certain participating stores.  Please allow 7 days from purchase date for UPS Ground delivery.  No expiration date and no service fee!   This offer cannot be combined with Promotion Codes."
  end

  it 'inserts Barnes & Nobles with the correct amounts' do
    subject.invoke

    barnes = rewards[1]
    barnes.amounts.map(&:dollar_award_amount).map(&:to_i).should == [10, 25, 50]
    barnes.award_code.should == 'barnes-gift-card'
    barnes.description.should == "The Barnes &amp; Noble eGift Card can be redeemed at any Barnes &amp; Noble store and online at BN.com (www.bn.com) – where you'll find an amazing selection of books, NOOK Books&trade;, (eBooks), CDs, DVDs, toys, games, and more. It can also be redeemed for NOOK eReader devices."
    barnes.is_active.should be_true
    barnes.is_redeemable.should be_true
    barnes.is_tango.should be_true
    barnes.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/barnesandnoble.png'
    barnes.name.should == "Barnes &amp; Noble eGift Card"
    barnes.terms.should == "* Barnes &amp; Noble is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. A Barnes &amp; Noble eGift Card may be used to purchase annual memberships in the Barnes &amp; Noble Membership program (continuous billing memberships require a valid credit card). Dormancy fees do not apply to balances on Barnes &amp; Noble eGift Cards. The Barnes &amp; Noble eGift Card will not be exchangeable for cash, except where required by law. Barnes &amp; Noble will not be responsible for lost or stolen Barnes &amp; Noble eGift Cards. If you have any additional Barnes &amp; Noble eGift Card questions, get Barnes &amp; Noble eGift Card Help at http://www.barnesandnoble.com/gc/gc_about_card.asp?cds2Pid=17599&linkid=1035340."
  end

  it 'inserts home depot with the correct amounts' do
    subject.invoke

    home = rewards[2]
    home.amounts.map(&:dollar_award_amount).map(&:to_i).should == [10, 15, 25]
    home.award_code.should == 'home-gift-card'
    home.description.should == "The Home Depot&reg; is the world's largest home improvement specialty retailer and they have something for everybody, from the novice painter to the gardening master.  With The Home Depot&reg; eGift Card you can shop at more than 2,200 retail locations throughout the U.S., Canada, and Mexico and online at www.homedepot.com.  The Home Depot&reg; – revolutionizing the home improvement industry by bringing the know-how and the tools to the consumer. More saving."
    home.is_active.should be_true
    home.is_redeemable.should be_true
    home.is_tango.should be_true
    home.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/HomeDepot.png'
    home.name.should == "The Home Depot&reg; eGift Card"
    home.terms.should == "* Plink is not affiliated with The Home Depot&reg;. The Home Depot&reg; is not a sponsor of this promotion. The Home Depot&reg; is a registered trademark of Homer TLC, Inc. Valid toward purchase of merchandise/services at any The Home Depot&reg; store in the U.S., Canada and online at HomeDepot.com. Gift Card carries no implied warranties and is not a credit/debit card. Not redeemable for cash (unless required by law) and cannot be applied to any credit or loan balance, Tool Rental deposits, or for in-home/phone purchases.  Gift Cards will not be cancelled and replaced without proof of purchase. Except as required by law, Gift Cards purchased with cash will not be replaced and any Gift Card may be deactivated or rejected in connection with fraudulent actions. Check your balance at any The Home Depot store or online. Reload card value at any The Home Depot store.  &copy; 2013. HOMER TLC, Inc. All rights reserved.  Redeemable in local funds at Home Depot's then applicable exchange rate."
  end

  it 'inserts starbucks with the correct amounts' do
    subject.invoke

    starbucks = rewards[3]
    starbucks.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 25, 50]
    starbucks.award_code.should == 'starbucks-gift-card'
    starbucks.description.should == "A Starbucks Card can bring a little goodness into everyone's day. Whether you use it for  your favorite flavored ice tea or give one to a friend who loves her morning mocha, it's a great way for you or a loved one to enjoy a slice of happiness."
    starbucks.is_active.should be_true
    starbucks.is_redeemable.should be_true
    starbucks.is_tango.should be_true
    starbucks.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Starbucks.png'
    starbucks.name.should == "Starbucks eGift Card"
    starbucks.terms.should == "The Starbucks word mark and the Starbucks Logo are trademarks of Starbucks Corporation. Starbucks is also the owner of the Copyrights in the Starbucks Logo and the Starbucks Card designs. All rights reserved. Starbucks is not a participating partner or sponsor in this offer. Reload your eGift and check your balance at participating Starbucks stores, www.starbucks.com/card or 1-800-782-7282. Your Starbucks Card eGift may only be used for making purchases at participating Starbucks stores. It cannot be redeemed for cash unless required by law. Refunds can only be provided for unused eGifts with the original receipt. This eGift does not expire, nor does Starbucks charge fees. Complete terms and conditions available on our website. Use of this eGift constitutes acceptance of these terms and conditions. Treat this eGift like Cash. "
  end

  it 'inserts target with the correct amounts' do
    subject.invoke

    target = rewards[4]
    target.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 15, 25]
    target.award_code.should == 'target-gift-card'
    target.description.should == "A Target eGiftCard is your opportunity to shop for thousands of items at more than 1,700 Target and SuperTarget&reg; stores in the U.S., as well as Target.com. From home decor, small appliances and electronics to fashion, accessories and music, find exactly what you're looking for at Target. No fees. No expiration. No kidding.&reg;"
    target.is_active.should be_true
    target.is_redeemable.should be_true
    target.is_tango.should be_true
    target.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Target.png'
    target.name.should == "Target eGift Card"
    target.terms.should == "The Bullseye Design, Target and Target GiftCards are registered trademarks of Target Brands Inc. Terms and conditions are applied to gift cards. Target is not a participating partner in or sponsor of this offer."
  end

  it 'inserts staples with the correct amounts' do
    subject.invoke

    staples = rewards[5]
    staples.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 15, 25]
    staples.award_code.should == 'staples-gift-card'
    staples.description.should == "Giving the perfect gift has never been easier! Whatever the season or reason, a Staples gift card makes a great gift. With thousands of options, there's something for everyone — digital cameras, GPS, laptops, printers and more!"
    staples.is_active.should be_true
    staples.is_redeemable.should be_true
    staples.is_tango.should be_true
    staples.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Staples.png'
    staples.name.should == "Staples Gift Card"
    staples.terms.should == "*Staples is not a sponsor of the rewards or promotion or otherwise affiliated with [company name]. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates. &copy; 2013 Staples International, Inc. The Staples logo is a registered trademark and copyrighted work of Staples International, Inc. PROTECT THIS CARD LIKE CASH! Instructions: This card may be used just like cash toward the purchase of merchandise and services at any Staples U.S. retail store; your receipt will show the remaining balance on the card. For balance, or if you have questions, call 1-888-609-6963 or visit staples.com/giftcards. Value can be added to this card at any Staples U.S. retail store. Terms and Conditions: Valid only if purchased from a Staples U.S. retail store, at staples.com&reg; or from an authorized reseller or distributor, or received from an authorized distributor; Staples reserves the right to not honor cards obtained from unauthorized sellers, including Internet auction sites. Card has no value until activated. Lost, stolen or damaged cards replaced only with valid proof of purchase to extent of remaining card balance. May be used only in Staples U.S. retail stores. Cannot be used for credit card payments or to purchase other gift cards (including Staples Gift Cards) or wireless cards. Not redeemable for cash or credit except where required by law. No more than five cards may be used for any single purchase. Cards may not be consolidated. Card issued by Staples Value, LLC. "
  end

  it 'inserts sears with the correct amounts' do
    subject.invoke

    sears = rewards[6]
    sears.amounts.map(&:dollar_award_amount).map(&:to_i).should == [15, 25]
    sears.award_code.should == 'sears-gift-card'
    sears.description.should == "The Sears Gift Card offers endless smiles and amazing possibilities.  With no expiration, get the brands and products you want at Sears, Kmart, and Lands' End, both online and in store when you want.  It's the perfect card for home, apparel, jewelry, electronics, automotive, lawn &amp; garden and much more."
    sears.is_active.should be_true
    sears.is_redeemable.should be_true
    sears.is_tango.should be_true
    sears.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Sears.png'
    sears.name.should == "Sears Gift Card"
    sears.terms.should == "* Sears is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. This card is issued by SHC Promotions LLC and is redeemable for goods and services at participating Sears, Roebuck and Co., Lands' End, The Great Indoors, and Kmart store locations in the U.S., P.R., Guam and U.S.V.I., and at sears.com, kmart.com, landsend.com and Lands' End catalogs. Not valid for purchase of third party debit or prepaid cards. Not redeemable for restaurant, Olan Mills Portrait Studio transactions or for cash, except where required by law. Cannot be applied to credit accounts. Lost, stolen or damaged gift cards may only be cancelled and replaced with proof of purchase. &copy; 2013 SHC Promotions LLC. "
  end

  it 'inserts papa johns with the correct amounts' do
    subject.invoke

    papa = rewards[7]
    papa.amounts.map(&:dollar_award_amount).map(&:to_i).should == [10]
    papa.award_code.should == 'papa-gift-card'
    papa.description.should == "Papa John's has a gift card that really delivers, because we're committed to quality. We use only the finest ingredients, from fresh-sliced vegetables to our fresh, never-frozen, hand-tossed dough. It's quality that you can taste. We believe that Better Ingredients make a Better Tasting Pizza. Gift card is redeemable by phone, in restaurants and online. There are more than 2,800 restaurants in the U.S., including Alaska and Hawaii. No expiration date and no service fees."
    papa.is_active.should be_true
    papa.is_redeemable.should be_true
    papa.is_tango.should be_true
    papa.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/PapaJohns.png'
    papa.name.should == "Papa John's Gift Card"
    papa.terms.should == "* Papa John's is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. Redeemable for the purchase of food, beverage, and gratuity at participating Papa John's. Verification may be required if the card is used other than by physical presentation (such as telephone ordering or online ordering). If the card is lost, stolen, damaged or destroyed, it will not be replaced or replenished and you will lose any remaining value on the card. To inquire about the card balance, call 1-800-325-1119. For a location near you visit their website at www.papajohns.com. Please treat this eGift Card like cash and safeguard it accordingly."
  end

  it 'inserts kmart with the correct amounts' do
    subject.invoke

    kmart = rewards[8]
    kmart.amounts.map(&:dollar_award_amount).map(&:to_i).should == [25]
    kmart.award_code.should == 'kmart-gift-card'
    kmart.description.should == "Kmart offers a wide selection of top quality merchandise from well-known labels as Jaclyn Smith, Joe Boxer, and Martha Stewart at exceptional prices."
    kmart.is_active.should be_true
    kmart.is_redeemable.should be_true
    kmart.is_tango.should be_true
    kmart.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Kmart.png'
    kmart.name.should == "Kmart Digital Gift Card"
    kmart.terms.should == "*Kmart is not a sponsor of the rewards or promotion or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions. This card is issued by SHC Promotions, LLC and is redeemable for merchandise and services purchased in conjunction with merchandise at participating Kmart, Sears, Lands' End, and The Great Indoors store locations, except restaurant or Portrait Studio transactions, in the U.S., Puerto Rico, Guam and the U.S. Virgin Islands, and at kmart.com, sears.com, landsend.com and Lands' End consumer catalogs. It cannot be redeemed for cash or applied to your Kmart, Sears, Lands' End, or The Great Indoors credit accounts, except where required by law. Lost, stolen or damaged gift cards may only be cancelled and replaced with the required proof of purchase. &copy; Kmart Corporation. For your balance inquiry call 1-800-922-5511. Visit our website at www.kmart.com. "
  end

  it 'inserts dominos with the correct amounts' do
    subject.invoke

    domino = rewards[9]
    domino.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 15, 25]
    domino.award_code.should == 'dominos-gift-card'
    domino.description.should == "Domino's is more than pizza! Try one of three varieties of stuffed cheesy bread, a delicious variety of Domino's Artisan&trade;  specialty pizzas, Oven Baked Sandwiches, Parmesan Bread Bites, or Chocolate Lava Crunch Cakes. Order online at www.dominos.com for lunch, dinner, or your next occasion."
    domino.is_active.should be_true
    domino.is_redeemable.should be_true
    domino.is_tango.should be_true
    domino.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/Dominos.png'
    domino.name.should == "Domino's Pizza eGift Card"
    domino.terms.should == "Participation by Domino's Pizza in the program is not intended as, and shall not constitute, a promotion or marketing of the program by Domino's Pizza. Prices, participation, delivery area and charges may vary, including AK and HI. Returned checks, along with the state's maximum allowable returned check fee, may be electronically presented to your bank. &copy;2013 Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC Usable up to balance only to buy goods or services at participating Domino's Pizza stores in the U.S. Not redeemable to purchase gift cards. Not redeemable for cash except as required by law. Not a credit or debit card. Safeguard the card. It will not be replaced or replenished if lost, stolen or used without authorization. CARDCO CXXV, Inc. is the card issuer and sole obligor to card owner. CARDCO may delegate its issuer obligations to an assignee, without recourse. If delegated, the assignee, and not CARDCO, will be sole obligor to card owner. Resale by any unlicensed vendor or through any unauthorized channels such as online auctions is prohibited. Purchase, use or acceptance of card constitutes acceptance of these terms. For balance inquiries go to www.dominos.com or call 877-250-2278 and for other inquiries visit www.dominos.com. Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC. "
  end

  it 'inserts burger king with the correct amounts' do
    subject.invoke

    bk = rewards[10]
    bk.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 15, 25]
    bk.award_code.should == 'bk-gift-card'
    bk.description.should == "The original HOME OF THE WHOPPER&reg;, our commitment to premium ingredients, signature recipes, and family-friendly dining experiences is what has defined our brand for more than 50 successful years."
    bk.is_active.should be_true
    bk.is_redeemable.should be_true
    bk.is_tango.should be_true
    bk.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/BurgerKing.png'
    bk.name.should == "BK&reg; eGift Card"
    bk.terms.should == "*BURGER KING&reg; is not a sponsor of the rewards or promotion or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates. Prices, participation, delivery area and charges may vary, including AK and HI. Returned checks, along with the state's maximum allowable returned check fee, may be electronically presented to your bank. &copy;2013 Dominos IP Holder LLC. Dominos&reg;, Domino's Pizza&reg; and the modular logo are trademarks of Domino's IP Holder LLC When you buy or receive a BK&reg; eGift, the following additional terms and conditions shall apply. A BK&reg; eGift is an electronic version of the BK Crown Card that may be purchased online where available or received and/or awarded as a prize in connection with certain BKC online and social media promotional activities. BK&reg; eGifts are not re-loadable and are delivered to the recipient in the form of a sixteen (16) digit code via e-mail or on the recipient's designated social media web page, including a Facebook page. BK&reg; eGifts can only be redeemed by presenting the sixteen (16) digit code at Participating Restaurants by showing a crew member the code on your smartphone or in printed format. The value of your BK&reg; eGift, monetary or otherwise, will not be replaced by BKC if your BK&reg; eGift is lost, stolen or damaged. You should protect your BK&reg; eGift account number. If you share your account number, others may redeem the gift resulting in a depletion or total loss of the value of your BK&reg; eGift "
  end

  it 'inserts best buy with the correct amounts' do
    subject.invoke

    bestbuy = rewards[11]
    bestbuy.amounts.map(&:dollar_award_amount).map(&:to_i).should == [5, 10, 25]
    bestbuy.award_code.should == 'bestbuy-gift-card'
    bestbuy.description.should == "Best Buy is the global leader in consumer electronics, offering the latest devices and services all in one place. And at BestBuy.com, you can shop when and where you want."
    bestbuy.is_active.should be_true
    bestbuy.is_redeemable.should be_true
    bestbuy.is_tango.should be_true
    bestbuy.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/BestBuy.png'
    bestbuy.name.should == "Best Buy eGift Card"
    bestbuy.terms.should == "* Best Buy is not a sponsor of the rewards or otherwise affiliated with Plink. The logos and other identifying marks attached are trademarks of and owned by each represented company and/or its affiliates.  Please visit each company's website for additional terms and conditions.  All U.S. Gift Cards are redeemable in any U.S. and Puerto Rico Best Buy retail locations, or online at BestBuy.com where available, for merchandise or services including Geek Squad services.  No expiration date; no fees Not redeemable for cash. Lost, stolen or damaged cards replaced only with valid proof of purchase to the extent of remaining card balance. Not a credit or debit card. Not valid as payment on a Best Buy credit card. Check Gift Card balance at any U.S. and Puerto Rico Best Buy retail locations, online at BestBuy.com or call 1-888-716-7994 with Gift Card number. Receipt will show remaining Gift Card balance. Physical Gift Cards may be reloaded at any U.S. and Puerto Rico Best Buy retail locations. All terms enforced except where prohibited by law. Purchases of a physical Gift Card in any Best Buy retail location or online at Bestbuy.com are eligible for Reward Zone points, excluding Best Buy for Business or commercial purchases of Gift Cards. "
  end
end
