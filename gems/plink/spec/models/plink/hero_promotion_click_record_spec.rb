require 'spec_helper'

describe Plink::HeroPromotionClickRecord do
  let(:valid_params) do
    {
      hero_promotion_id: 12,
      user_id: 2
    }
  end

  it { should allow_mass_assignment_of(:hero_promotion_id) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should validate_presence_of(:hero_promotion_id) }
  it { should validate_presence_of(:user_id) }

  it 'can be persisted' do
    hero_promotion_click_record = Plink::HeroPromotionClickRecord.create(valid_params)

    hero_promotion_click_record.should be_persisted
  end
end
