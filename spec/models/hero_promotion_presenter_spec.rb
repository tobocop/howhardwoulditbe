require 'spec_helper'

describe HeroPromotionPresenter do
  let(:hero_promotion) {
    double(
      id: 4,
      image_url_one: 'valid_image_url',
      image_url_two: 'valid_image_url_right',
      link_one: 'my_left_link',
      link_two: 'my_right_link',
      same_tab_one: true,
      same_tab_two: true,
      title: 'the best promo ever'
    )
  }

  subject(:presenter) { HeroPromotionPresenter.new(hero_promotion, 3) }

  it 'can be initialized with a hero promotion' do
    presenter.id.should == 4
    presenter.image_url_left.should == 'valid_image_url'
    presenter.image_url_right.should == 'valid_image_url_right'
    presenter.link_left.should == 'my_left_link'
    presenter.link_right.should == 'my_right_link'
    presenter.title.should == 'the best promo ever'
  end

  describe '#link_target_for_left_url' do
    it 'returns the string _self if same_tab_one is true' do
      presenter.link_target_for_left_url.should == '_self'
    end

    it 'returns the string _blank if same_tab_one is false' do
      hero_promotion.stub(:same_tab_one).and_return(false)
      presenter.link_target_for_left_url.should == '_blank'
    end
  end

  describe '#link_target_for_right_url' do
    it 'returns the string _self if same_tab_two is true' do
      presenter.link_target_for_right_url.should == '_self'
    end

    it 'returns the string _blank if same_tab_two is false' do
      hero_promotion.stub(:same_tab_two).and_return(false)
      presenter.link_target_for_right_url.should == '_blank'
    end
  end

  describe '#left_and_right_promotion?' do
    it 'returns true if a right_image_url is present' do
      presenter.left_and_right_promotion?.should be_true
    end

    it 'returns false if a right_image_url is not present' do
      hero_promotion.stub(:image_url_two).and_return('')
      presenter.left_and_right_promotion?.should be_false
    end
  end
end
