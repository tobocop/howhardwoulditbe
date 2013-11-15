require 'spec_helper'

describe Plink::HeroPromotion do
  it 'populates its data from the given attributes' do
    hero_promotion = Plink::HeroPromotion.new(
      {
        title: 'Michael Jordan',
        image_url: '/mj_and_bb.jpg',
        link: 'www.google.com',
        show_linked_users: true,
        show_non_linked_users: false
      }
    )

    hero_promotion.title.should == 'Michael Jordan'
    hero_promotion.image_url.should == '/mj_and_bb.jpg'
    hero_promotion.link.should == 'www.google.com'
    hero_promotion.show_linked_users.should == true
    hero_promotion.show_non_linked_users.should == false
  end
end
