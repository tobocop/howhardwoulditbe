require 'spec_helper'

describe PlinkAdmin::RegistrationLinkHelper do
  describe '#generate_registration_link_url' do
    let(:plink_admin) { double(registration_link_url: registration_link_url) }
    let(:registration_link_url) { double(gsub: 'stuff/other_stuff') }

    before do
      helper.stub(:plink_admin).and_return(plink_admin)
    end

    it 'it scopes the route to plink_admin' do
      helper.should_receive(:plink_admin).and_return(plink_admin)

      helper.generate_registration_link_url(1).should == 'stuff/other_stuff'
    end

    it 'uses the registration link url route' do
      plink_admin.should_receive(:registration_link_url).with(1)
        .and_return(registration_link_url)

      helper.generate_registration_link_url(1).should == 'stuff/other_stuff'
    end

    it 'removes plink_admin and replaces it with nothing' do
      registration_link_url.should_receive(:gsub).with(/plink_admin\//, '')
        .and_return('stuff/other_stuff')

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
