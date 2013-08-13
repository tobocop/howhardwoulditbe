namespace :reward do

  # TODO: Remove this and its spec after execution
  desc 'One-time task to update rewards text'
  task :update_reward_records_text do
    amazon = Plink::RewardRecord.where(name: 'Amazon.com Gift Card', isActive: true).first
    amazon.update_attributes(description: 'Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.')

    zappos = Plink::RewardRecord.where(name: 'Zappos.com Gift Card', isActive: true).first
    zappos.update_attributes(description: 'Free shipping BOTH ways on shoes, clothing, and more! Over 1000 brands and 24/7 friendly customer service.')

    regal = Plink::RewardRecord.where(name: 'Regal Cinemas Gift Card', isActive: true).first
    regal.update_attributes(description: 'The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.')

    tango_card = Plink::RewardRecord.where(name: 'Tango Card', isActive: true).first
    tango_card.update_attributes(description: 'Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click <a href="https://www.tangocard.com/what-is" target="_blank">here</a> for more information.')

    walmart = Plink::RewardRecord.where(name: 'Walmart Gift Card', isActive: true).first
    walmart.update_attributes(description: 'The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.')

    american_airlines = Plink::RewardRecord.where(name: 'Airline Miles', isActive: true).first
    american_airlines.update_attributes(description: 'Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.')

    itunes = Plink::RewardRecord.where(name: 'iTunes&reg; Gift Card', isActive: true).first
    itunes.update_attributes(description: 'iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.')

    american_red_cross = Plink::RewardRecord.where(name: 'Red Cross donation', isActive: true).first
    american_red_cross.update_attributes(description: "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families.")
  end

end
