require 'spec_helper'

describe Plink::IntuitRequestRecord do
  it { should allow_mass_assignment_of(:processed) }
  it { should allow_mass_assignment_of(:response) }
  it { should allow_mass_assignment_of(:user_id) }
end
