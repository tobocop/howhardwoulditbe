require 'spec_helper'

describe 'reward:update_reward_descriptions', skip_in_build: true do
  include_context 'rake'

  let(:amazon) { create_reward(name: 'Amazon.com Gift Card') }
  let(:walmart) { create_reward(name: 'Walmart Gift Card') }
  let(:itunes) { create_reward(name: 'iTunes&reg; Gift Card') }
  let(:tango_card) { create_reward(name: 'Tango Card') }
  let(:facebook) { create_reward(name: 'Facebook Credits') }
  # subway (created separately)
  let(:american_red_cross) { create_reward(name: 'Red Cross donation') }
  let(:regal) { create_reward(name: 'Regal Cinemas Gift Card') }
  let(:overstock) { create_reward(name: 'Overstock.com Gift Card') }
  let(:barnes_and_noble) { create_reward(name: 'Barnes and Noble Gift Card') }
  let(:airline_miles) { create_reward(name: 'Airline Miles') }

  it 'updates the description & terms field for the appropriate rewards' do
    rewards = [amazon, walmart, itunes, tango_card, facebook, american_red_cross, regal, overstock, barnes_and_noble, airline_miles]

    rewards.each do |reward|
      reward.description.should == 'howl at the moon'
    end

    subject.invoke

    amazon.reload.description.should == 'Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.'
    amazon.reload.terms.should == '*Amazon.com is not a sponsor of this promotion. Except as required by law, Amazon.com Gift Cards ("GCs") cannot be transferred for value or redeemed for cash. GCs may be used only for purchases of eligible goods on Amazon.com or certain of its affiliated websites. For complete terms and conditions, see www.amazon.com/gc-legal. GCs are issued by ACI Gift Cards, Inc., a Washington corporation. &copy;,&reg;,&trade; Amazon.com Inc. and/or its affiliates, 2012. No expiration date or service fees'

    walmart.reload.description.should == 'The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.'
    walmart.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Walmart.  Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="http://www.walmart.com/ip/Walmart-Basic-Blue-eGift-Card/3223392" target="_blank">Click here</a> for a full description of Walmarts eGift Cards.'

    itunes.reload.description.should == 'iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.'
    itunes.reload.terms.should == '* Valid only on iTunes&reg; Store for U.S. Requires iTunes&reg; account and prior acceptance of license and usage terms. To open an account you must be 13+ and in the U.S. Compatible software, hardware, and Internet access required. Not redeemable for cash, no refunds or exchanges (except as required by law). Code may not be used to purchase any other merchandise, allowances or iTunes&reg; gifting. Data collection and use subject to Apple Customer Privacy Policy, see www.apple.com/privacy, unless stated otherwise. Risk of loss and title for code passes to purchaser on transfer. Codes are issued and managed by Apple Value Services, LLC ("Issuer"). Neither Apple nor Issuer is responsible for any loss or damage resulting from lost or stolen codes or use without permission. Apple and its licensees, affiliates, and licensors make no warranties, express or implied, with respect to code or the iTunes&reg; Store and disclaim any warranty to the fullest extent available. These limitations may not apply to you. Void where prohibited. Not for resale. Subject to full terms and conditions, see www.apple.com/legal/itunes/us/gifts.html. Content and pricing subject to availability at the time of actual download. Content purchased from the iTunes&reg; Store is for personal lawful use only. Dont steal music. &copy; 2012 Apple Inc. All rights reserved.  iTunes&reg; is a registered trademark of Apple Inc., All rights reserved.  Apple is not a participant in or sponsor of this promotion.'

    tango_card.reload.description.should == 'Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click <a href="https://www.tangocard.com/what-is" target="_blank">here</a> for more information.'
    tango_card.reload.terms.should == '<a href="https://www.tangocard.com/terms-of-service" target="_blank">Subject to Tango Card Terms of Service</a>'

    facebook.reload.description.should == 'Get Virtual Goods in Your Favorite Games'
    facebook.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Facebook.  Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="https://developers.facebook.com/policy/credits/" target="_blank">Click here</a> to visit Facebook e-gift card terms & conditions.'

    # # subway

    american_red_cross.reload.description.should == "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families."
    american_red_cross.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Red Cross.'

    regal.reload.description.should == 'The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.'
    regal.reload.terms.should == 'Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption.  <a href="http://www.regmovies.com/" target="_blank">Click here</a> to find locations near you.'

    overstock.reload.description.should == 'Overstock. Let the savings begin!'
    overstock.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Overstock.com.  Electronic gift cards are fullfiled by Plink and will be delivered via email within two business days of redemption. <a href="http://www.overstock.com/e-gift-cards.html#termsCondLong" target="_blank">Click here</a> to visit Overstocks e-gift card terms &amp; conditions.'

    barnes_and_noble.reload.description.should == 'Lower Prices on Millions of Books, Movies and TV Show DVDs and Blu-ray, Music, Toys, and Games.'
    barnes_and_noble.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Barnes &amp; Noble. Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="http://www.barnesandnoble.com/gc/gc_tandc.asp?x=&PID=17843" target="_blank">Click here</a> for Barnes &amp; Nobles eGift Cards Terms &amp; Conditions.'

    airline_miles.reload.description.should == 'Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.'
    airline_miles.reload.terms.should == 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Airline Miles Programs. Electronic gift cards are fulfilled by Plink and will be delivered via email within two business of redemption.'
  end
end

describe 'reward:update_display_order', skip_in_build: true do
  include_context 'rake'

  let!(:amazon) { create_reward(name: 'Amazon.com Gift Card') }
  let!(:walmart) { create_reward(name: 'Walmart Gift Card') }
  let!(:itunes) { create_reward(name: 'iTunes&reg; Gift Card') }
  let!(:tango_card) { create_reward(name: 'Tango Card') }
  let!(:facebook) { create_reward(name: 'Facebook Credits') }
  # subway (created separately)
  let!(:american_red_cross) { create_reward(name: 'Red Cross donation') }
  let!(:regal) { create_reward(name: 'Regal Cinemas Gift Card') }
  let!(:overstock) { create_reward(name: 'Overstock.com Gift Card') }
  let!(:barnes_and_noble) { create_reward(name: 'Barnes and Noble Gift Card') }
  let!(:airline_miles) { create_reward(name: 'Airline Miles') }
  let!(:old_reward) { create_reward(name: 'old', display_order: '1')}

  before { subject.invoke }

  it 'sets position to null for all old rewards' do
    old_reward.reload.display_order.should be_nil
  end

  it 'sets the correct display order for rewards' do
    amazon.reload.display_order.should == 1
    walmart.reload.display_order.should == 2
    itunes.reload.display_order.should == 3
    tango_card.reload.display_order.should == 4
    facebook.reload.display_order.should == 5
    # subway (created separately) = 6
    american_red_cross.reload.display_order.should == 7
    regal.reload.display_order.should == 8
    overstock.reload.display_order.should == 9
    barnes_and_noble.reload.display_order.should == 10
    airline_miles.reload.display_order.should == 11
  end
end

describe 'reward:update_reward_amounts', skip_in_build: true do
  include_context 'rake'

  let(:old_reward) { create_reward }
  let!(:old_reward_amount) { create_reward_amount(reward_id: old_reward.id) }

  let!(:amazon) { create_reward(name: 'Amazon.com Gift Card') }
  let!(:walmart) { create_reward(name: 'Walmart Gift Card') }
  let!(:itunes) { create_reward(name: 'iTunes&reg; Gift Card') }
  let!(:tango_card) { create_reward(name: 'Tango Card') }
  let!(:facebook) { create_reward(name: 'Facebook Credits') }
  let!(:american_red_cross) { create_reward(name: 'Red Cross donation') }
  let!(:regal) { create_reward(name: 'Regal Cinemas Gift Card') }
  let!(:overstock) { create_reward(name: 'Overstock.com Gift Card') }
  let!(:barnes_and_noble) { create_reward(name: 'Barnes and Noble Gift Card') }
  let!(:airline_miles) { create_reward(name: 'Airline Miles') }

  before { subject.invoke }

  it 'marks existing rewards amounts as inactive' do
    old_reward_amount.reload.is_active.should be_false
  end

  context 'creates new reward amount records for the' do
    it 'Amazon.com Gift Card' do
      amounts = amazon.reload.amounts.map(&:dollar_award_amount)

      amounts.should include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Walmart Gift Card' do
      amounts = walmart.reload.amounts.map(&:dollar_award_amount)

      amounts.should include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'iTunes&reg; Gift Card' do
      amounts = itunes.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Tango Card' do
      amounts = tango_card.reload.amounts.map(&:dollar_award_amount)

      amounts.should include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Facebook Credits' do
      amounts = facebook.reload.amounts.map(&:dollar_award_amount)

      amounts.should include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Red Cross donations' do
      amounts = american_red_cross.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Regal Cinemas Gift Card' do
      amounts = regal.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Overstock.com Gift Card' do
      amounts = overstock.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Barnes and Noble Gift Card' do
      amounts = barnes_and_noble.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end

    it 'Airline Miles' do
      amounts = airline_miles.reload.amounts.map(&:dollar_award_amount)

      amounts.should_not include 5
      amounts.should include 10
      amounts.should include 15
      amounts.should include 25
      amounts.should include 50
      amounts.should include 100
    end
  end
end

describe 'reward:add_subway', skip_in_build: true do
  include_context 'rake'

  let(:subway) { Plink::RewardRecord.last }

  before { subject.invoke }

  it 'adds a reward record with production values' do
    subway.award_code.should == 'subway-gift-card'
    subway.name.should == 'Subway Gift Card'
    subway.description.should == "Redeem your SUBWAY&reg; Card today, and you'll always have a delicious meal right at your fingertips."
    subway.terms.should == 'Subway gift cards are a physical gift card that will be mailed to your home address.  Please allow up to 3-5 business days for a Plink team member to contact you via your registered Plink email, asking for your mailing address. The gift card should arrive within a week of your response.'
    subway.logo_url.should == 'https://plink-images.s3.amazonaws.com/rewardImages/subway.png'
    subway.display_order.should == 6
  end

  it 'adds redemption values of $10 and $20' do
    dollar_amounts = subway.amounts.map(&:dollar_award_amount)
    dollar_amounts.should include 10
    dollar_amounts.should include 20
    dollar_amounts.should include 30
    dollar_amounts.should include 40
    dollar_amounts.should include 50
    dollar_amounts.should include 100
  end
end
