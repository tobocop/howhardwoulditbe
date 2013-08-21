namespace :reward do

  # TODO: Remove this and its spec after execution
  desc 'One-time task to update rewards text and legal terms'
  task update_reward_descriptions: :environment do
    amazon = Plink::RewardRecord.where(name: 'Amazon.com Gift Card', isActive: true).first
    amazon.update_attributes(
      description: 'Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.',
      terms: '*Amazon.com is not a sponsor of this promotion. Except as required by law, Amazon.com Gift Cards ("GCs") cannot be transferred for value or redeemed for cash. GCs may be used only for purchases of eligible goods on Amazon.com or certain of its affiliated websites. For complete terms and conditions, see www.amazon.com/gc-legal. GCs are issued by ACI Gift Cards, Inc., a Washington corporation. &copy;,&reg;,&trade; Amazon.com Inc. and/or its affiliates, 2012. No expiration date or service fees'
    )

    walmart = Plink::RewardRecord.where(name: 'Walmart Gift Card', isActive: true).first
    walmart.update_attributes(
      description: 'The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.',
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Walmart.  Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="http://www.walmart.com/ip/Walmart-Basic-Blue-eGift-Card/3223392" target="_blank">Click here</a> for a full description of Walmarts eGift Cards.'
    )

    itunes = Plink::RewardRecord.where(name: 'iTunes&reg; Gift Card', isActive: true).first
    itunes.update_attributes(
      description: 'iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.',
      terms: '* Valid only on iTunes&reg; Store for U.S. Requires iTunes&reg; account and prior acceptance of license and usage terms. To open an account you must be 13+ and in the U.S. Compatible software, hardware, and Internet access required. Not redeemable for cash, no refunds or exchanges (except as required by law). Code may not be used to purchase any other merchandise, allowances or iTunes&reg; gifting. Data collection and use subject to Apple Customer Privacy Policy, see www.apple.com/privacy, unless stated otherwise. Risk of loss and title for code passes to purchaser on transfer. Codes are issued and managed by Apple Value Services, LLC ("Issuer"). Neither Apple nor Issuer is responsible for any loss or damage resulting from lost or stolen codes or use without permission. Apple and its licensees, affiliates, and licensors make no warranties, express or implied, with respect to code or the iTunes&reg; Store and disclaim any warranty to the fullest extent available. These limitations may not apply to you. Void where prohibited. Not for resale. Subject to full terms and conditions, see www.apple.com/legal/itunes/us/gifts.html. Content and pricing subject to availability at the time of actual download. Content purchased from the iTunes&reg; Store is for personal lawful use only. Dont steal music. &copy; 2012 Apple Inc. All rights reserved.  iTunes&reg; is a registered trademark of Apple Inc., All rights reserved.  Apple is not a participant in or sponsor of this promotion.'
    )

    tango_card = Plink::RewardRecord.where(name: 'Tango Card', isActive: true).first
    tango_card.update_attributes(
      description: 'Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click <a href="https://www.tangocard.com/what-is" target="_blank">here</a> for more information.',
      terms: '<a href="https://www.tangocard.com/terms-of-service" target="_blank">Subject to Tango Card Terms of Service</a>'
    )

    facebook = Plink::RewardRecord.where(name: 'Facebook Credits', isActive: true).first
    facebook.update_attributes(
      description: 'Get Virtual Goods in Your Favorite Games',
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Facebook.  Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="https://developers.facebook.com/policy/credits/" target="_blank">Click here</a> to visit Facebook e-gift card terms & conditions.'
    )

    american_red_cross = Plink::RewardRecord.where(name: 'Red Cross donation', isActive: true).first
    american_red_cross.update_attributes(
      description: "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families.",
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Red Cross.'
    )

    regal = Plink::RewardRecord.where(name: 'Regal Cinemas Gift Card', isActive: true).first
    regal.update_attributes(
      description: 'The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.',
      terms: 'Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption.  <a href="http://www.regmovies.com/" target="_blank">Click here</a> to find locations near you.'
    )

    overstock = Plink::RewardRecord.where(name: 'Overstock.com Gift Card', isActive: true).first
    overstock.update_attributes(
      description: 'Overstock. Let the savings begin!',
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Overstock.com.  Electronic gift cards are fullfiled by Plink and will be delivered via email within two business days of redemption. <a href="http://www.overstock.com/e-gift-cards.html#termsCondLong" target="_blank">Click here</a> to visit Overstocks e-gift card terms &amp; conditions.'
    )

    barnes_and_noble = Plink::RewardRecord.where(name: 'Barnes and Noble Gift Card', isActive: true).first
    barnes_and_noble.update_attributes(
      description: 'Lower Prices on Millions of Books, Movies and TV Show DVDs and Blu-ray, Music, Toys, and Games.',
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Barnes &amp; Noble. Electronic gift cards are fulfilled by plink and will be delivered via email within two business of redemption. <a href="http://www.barnesandnoble.com/gc/gc_tandc.asp?x=&PID=17843" target="_blank">Click here</a> for Barnes &amp; Nobles eGift Cards Terms &amp; Conditions.'
    )

    american_airlines = Plink::RewardRecord.where(name: 'Airline Miles', isActive: true).first
    american_airlines.update_attributes(
      description: 'Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.',
      terms: 'Plink is not affiliated, associated, authorized, endorsed by or in any way officially connected with Airline Miles Programs. Electronic gift cards are fulfilled by Plink and will be delivered via email within two business of redemption.'
    )
  end

  desc 'One-time task to set display order for rewards'
  task update_display_order: :environment do
    Plink::RewardRecord.update_all(displayOrder: nil)

    amazon = Plink::RewardRecord.where(name: 'Amazon.com Gift Card', isActive: true).first
    amazon.update_attributes(display_order: 1)

    walmart = Plink::RewardRecord.where(name: 'Walmart Gift Card', isActive: true).first
    walmart.update_attributes(display_order: 2)

    itunes = Plink::RewardRecord.where(name: 'iTunes&reg; Gift Card', isActive: true).first
    itunes.update_attributes(display_order: 3)

    tango_card = Plink::RewardRecord.where(name: 'Tango Card', isActive: true).first
    tango_card.update_attributes(display_order: 4)

    facebook = Plink::RewardRecord.where(name: 'Facebook Credits', isActive: true).first
    facebook.update_attributes(display_order: 5)

    american_red_cross = Plink::RewardRecord.where(name: 'Red Cross donation', isActive: true).first
    american_red_cross.update_attributes(display_order: 7)

    regal = Plink::RewardRecord.where(name: 'Regal Cinemas Gift Card', isActive: true).first
    regal.update_attributes(display_order: 8)

    overstock = Plink::RewardRecord.where(name: 'Overstock.com Gift Card', isActive: true).first
    overstock.update_attributes(display_order: 9)

    barnes_and_noble = Plink::RewardRecord.where(name: 'Barnes and Noble Gift Card', isActive: true).first
    barnes_and_noble.update_attributes(display_order: 10)

    american_airlines = Plink::RewardRecord.where(name: 'Airline Miles', isActive: true).first
    american_airlines.update_attributes(display_order: 11)
  end

  desc 'One-time task to set reward amounts'
  task update_reward_amounts: :environment do
    Plink::RewardAmountRecord.update_all(isActive: false)

    amazon = Plink::RewardRecord.where(name: 'Amazon.com Gift Card', isActive: true).first
    ['5', '10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: amazon.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    walmart = Plink::RewardRecord.where(name: 'Walmart Gift Card', isActive: true).first
    ['5', '10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: walmart.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    itunes = Plink::RewardRecord.where(name: 'iTunes&reg; Gift Card', isActive: true).first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: itunes.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    tango = Plink::RewardRecord.where(name: 'Tango Card', isActive: true).first
    ['5', '10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: tango.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    facebook = Plink::RewardRecord.where(name: 'Facebook Credits', isActive: true).first
    ['5', '10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: facebook.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    american_red_cross = Plink::RewardRecord.where(name: 'Red Cross donation', isActive: true).first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: american_red_cross.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    regal = Plink::RewardRecord.where(name: 'Regal Cinemas Gift Card').first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: regal.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    overstock = Plink::RewardRecord.where(name: 'Overstock.com Gift Card', isActive: true).first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: overstock.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    barnes_and_noble = Plink::RewardRecord.where(name: 'Barnes and Noble Gift Card', isActive: true).first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: barnes_and_noble.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end

    airline_miles = Plink::RewardRecord.where(name: 'Airline Miles', isActive: true).first
    ['10', '15', '25', '50', '100'].each do |dollar_value|
      Plink::RewardAmountRecord.create!({
        reward_id: airline_miles.id,
        is_active: true,
        dollar_award_amount: dollar_value
      })
    end
  end

  desc 'One-time task to add Subway'
  task add_subway: :environment do
    reward = Plink::RewardRecord.create!(
      award_code: 'subway-gift-card',
      name: 'Subway Gift Card',
      description: "Redeem your SUBWAY&reg; Card today, and you'll always have a delicious meal right at your fingertips.",
      terms: 'Subway gift cards are a physical gift card that will be mailed to your home address.  Please allow up to 3-5 business days for a Plink team member to contact you via your registered Plink email, asking for your mailing address. The gift card should arrive within a week of your response.',
      logo_url: 'https://plink-images.s3.amazonaws.com/rewardImages/subway.png',
      display_order: 6
    )

    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 10)
    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 20)
    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 30)
    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 40)
    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 50)
    reward.amounts << Plink::RewardAmountRecord.new(is_active: true, dollar_award_amount: 100)

    reward.save!
  end
end
