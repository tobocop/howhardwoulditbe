require 'spec_helper'

describe Plink::ContestWinnerRecord do
  it { should validate_presence_of(:contest_id) }
  it { should have_db_column(:rejected).of_type(:boolean) }

  it { should validate_presence_of(:user_id) }
  it { should have_db_column(:winner).of_type(:boolean) }

  it { should allow_mass_assignment_of(:admin_user_id) }
  it { should allow_mass_assignment_of(:contest_id) }
  it { should allow_mass_assignment_of(:finalized_at) }
  it { should allow_mass_assignment_of(:prize_level_id) }
  it { should allow_mass_assignment_of(:user_id) }
end
