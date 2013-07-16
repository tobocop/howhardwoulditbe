require 'spec_helper'

describe Plink::HeroPromotion do
  it 'populates its data from the given attributes' do
    hero_promotion = Plink::HeroPromotion.new(
      {
        title: 'Michael Jordan',
        image_url: '/mj_and_bb.jpg'
      }
    )

    hero_promotion.title.should == 'Michael Jordan'
    hero_promotion.image_url.should == '/mj_and_bb.jpg'
  end
end
