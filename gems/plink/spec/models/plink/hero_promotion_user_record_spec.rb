require 'spec_helper'

describe Plink::HeroPromotionUserRecord do
  it { should allow_mass_assignment_of(:hero_promotion_id) }
  it { should allow_mass_assignment_of(:user_id) }
end
