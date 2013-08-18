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

  it 'updates the description field for the appropriate rewards' do
    rewards = [amazon, walmart, itunes, tango_card, facebook, american_red_cross, regal, overstock, barnes_and_noble, airline_miles]

    rewards.each do |reward|
      reward.description.should == 'howl at the moon'
    end

    subject.invoke

    amazon.reload.description.should == 'Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.'
    walmart.reload.description.should == 'The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.'
    itunes.reload.description.should == 'iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.'
    tango_card.reload.description.should == 'Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click <a href="https://www.tangocard.com/what-is" target="_blank">here</a> for more information.'
    facebook.reload.description.should == 'Get Virtual Goods in Your Favorite Games'
    # subway
    american_red_cross.reload.description.should == "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families."
    regal.reload.description.should == 'The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.'
    overstock.reload.description.should == 'Overstock. Let the savings begin!'
    barnes_and_noble.reload.description.should == 'Lower Prices on Millions of Books, Movies and TV Show DVDs and Blu-ray, Music, Toys, and Games.'
    airline_miles.reload.description.should == 'Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.'
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
  end
end
