require 'spec_helper'

module Plink
  describe ContestBlacklistedEmailRecord do
    it { should validate_presence_of(:user_id) }

    it { should allow_mass_assignment_of(:user_id) }
  end
end
