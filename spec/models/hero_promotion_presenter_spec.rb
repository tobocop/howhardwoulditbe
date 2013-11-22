require 'spec_helper'

describe HeroPromotionPresenter do
  let(:hero_promotion) {
    double(
      id: 4,
      image_url: 'valid_image_url',
      image_url_right: 'valid_image_url_right',
      link: 'my_left_link',
      link_right: 'my_right_link',
      title: 'the best promo ever'
    )
  }

  subject(:presenter) { HeroPromotionPresenter.new(hero_promotion, 3, false) }

  it 'can be initialized with a hero promotion' do
    presenter.id.should == 4
    presenter.image_url.should == 'valid_image_url'
    presenter.image_url_right.should == 'valid_image_url_right'
    presenter.link.should == 'my_left_link'
    presenter.link_right.should == 'my_right_link'
    presenter.title.should == 'the best promo ever'
  end

  describe '#show_to_current_user?' do
    it 'returns true if hero_promotion.show_in_ui? is true' do
      hero_promotion.stub(:show_in_ui?).and_return(true)
      presenter.show_to_current_user?.should be_true
    end

    it 'returns false if hero_promotion.show_in_ui? is false' do
      hero_promotion.stub(:show_in_ui?).and_return(false)
      presenter.show_to_current_user?.should be_false
    end
  end

  describe '#left_and_right_promotions?' do
    it 'returns true if a right_image_url is present' do
      presenter.left_and_right_promotions?.should be_true
    end

    it 'returns false if a right_image_url is not present' do
      hero_promotion.stub(:image_url_right).and_return('')
      presenter.left_and_right_promotions?.should be_false
    end
  end
end
