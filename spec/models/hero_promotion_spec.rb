require 'spec_helper'

describe HeroPromotion do
  let(:valid_attributes) {
    {
        image_url: '/assets/foo.jpg',
        title: 'Yes',
        display_order: 1
    }
  }

  it 'can be valid' do
    HeroPromotion.new(valid_attributes).should be_valid
  end

end
