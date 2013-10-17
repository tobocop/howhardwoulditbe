require 'spec_helper'

describe Plink::SharePageTrackingRecord do
  it { should allow_mass_assignment_of(:registration_link_id) }
  it { should allow_mass_assignment_of(:shared) }
  it { should allow_mass_assignment_of(:share_page_id) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should validate_presence_of(:registration_link_id) }
  it { should validate_presence_of(:user_id) }

  it { should have_db_column(:shared).of_type(:boolean) }
end
