require 'spec_helper'

module Plink
  describe ContestBlacklistedEmailRecord do
    it { should validate_presence_of(:email_pattern) }

    it { should allow_mass_assignment_of(:email_pattern) }
  end
end
