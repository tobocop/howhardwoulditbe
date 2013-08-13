require 'spec_helper'

describe 'reward:update_reward_records_text', skip_in_build: true do
  include_context 'rake'

  let(:amazon) { create_reward(name: 'Amazon.com Gift Card') }
  let(:zappos) { create_reward(name: 'Zappos.com Gift Card') }
  let(:regal) { create_reward(name: 'Regal Cinemas Gift Card') }
  let(:tango_card) { create_reward(name: 'Tango Card') }
  let(:walmart) { create_reward(name: 'Walmart Gift Card') }
  let(:american_airlines) { create_reward(name: 'Airline Miles') }
  let(:itunes) { create_reward(name: 'iTunes&reg; Gift Card') }
  let(:american_red_cross) { create_reward(name: 'Red Cross donation') }

  it 'updates the description field for the appropriate rewards' do
    rewards = [amazon, zappos, regal, tango_card, walmart, american_airlines, itunes, american_red_cross]

    rewards.each do |reward|
      reward.description.should == 'howl at the moon'
    end

    subject.invoke

    amazon.reload.description.should == 'Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.'
    zappos.reload.description.should == 'Free shipping BOTH ways on shoes, clothing, and more! Over 1000 brands and 24/7 friendly customer service.'
    regal.reload.description.should == 'The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.'
    tango_card.reload.description.should == 'Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click <a href="https://www.tangocard.com/what-is" target="_blank">here</a> for more information.'
    walmart.reload.description.should == 'The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.'
    american_airlines.reload.description.should == 'Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.'
    itunes.reload.description.should == 'iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.'
    american_red_cross.reload.description.should == "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families."
  end
end


