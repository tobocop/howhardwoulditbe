require 'spec_helper'

describe PlinkAdmin::RegistrationLinkHelper do
  describe '#generate_registration_link_url' do
    it 'removes plink_admin and replaces it with nothing' do
      helper.should_receive(:registration_link_url).with(1).
        and_return('stuff/plink_admin/other_stuff')

      helper.generate_registration_link_url(1).should == 'stuff/other_stuff'
    end
  end

  describe '#present_share_state' do
    it 'returns "No" when given nil' do
      helper.present_share_state(nil).should == 'No'
    end

    it 'returns "Yes" when given true' do
      helper.present_share_state(true).should == 'Yes'
    end

    it 'returns "Decline" when given false' do
      helper.present_share_state(false).should == 'Decline'
    end
  end

  describe '#present_proportion' do
    it 'returns count / total in the format XX.YY% sign' do
      helper.present_proportion(1,2).should == '50.00%'
      helper.present_proportion(1,3).should == '33.33%'
      helper.present_proportion(0,3).should == '0.00%'
      helper.present_proportion(3,3).should == '100.00%'
    end
  end
end
