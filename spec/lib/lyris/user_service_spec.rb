require 'spec_helper'

describe Lyris::UserService do
  let(:ip) {'127.0.0.1'}
  let(:user_data) { {my_data: 'derp', ip: ip} }
  let(:lyris_user_double) { double(add_to_list: true, update_email: true) }
  let(:lyris_success_response) { double(successful?: true, data: 'email added') }
  let(:lyris_error_response) { double(successful?: false, data: 'email could not be added') }

  describe '#add_to_lyris' do
    let(:location_data) { {state: 'CO', city: 'Denver', zip: 80201} }
    let(:user_service_double) { double(update: true) }

    before do
      Lyris::UserService.stub(:get_location_data).and_return(location_data)
      Plink::UserService.stub(new: user_service_double)
    end

    it 'updates the users location data' do
      Lyris::UserService.unstub(:get_location_data)
      Lyris::UserDataCollector.stub(new: user_data)
      Lyris::User.stub(new: lyris_user_double)
      lyris_user_double.stub(add_to_list: lyris_success_response)

      Geoip::LocationLookup.should_receive(:by_ip)
        .with(ip)
        .and_return(location_data)
      user_service_double.should_receive(:update)
        .with(23, location_data)

      Lyris::UserService.add_to_lyris(23, 'lyris_user@exmaple.com', 'lyris vc')
    end

    it 'can add users to the lyris list' do
      Lyris::UserDataCollector.should_receive(:new).with(
        23, 'lyris vc'
      ).and_return(user_data)

      Lyris::User.should_receive(:new).with(
        Lyris::Config.instance,
        'lyris_user@exmaple.com',
        user_data
      ).and_return(lyris_user_double)
      lyris_user_double.should_receive(:add_to_list).and_return(lyris_success_response)

      Lyris::UserService.add_to_lyris(23, 'lyris_user@exmaple.com', 'lyris vc')
    end

    it 'sends errors to Exceptional in production' do
      Rails.env.stub(:production?).and_return(true)
      Lyris::UserDataCollector.stub(new: user_data)
      Lyris::User.stub(new: lyris_user_double)
      lyris_user_double.stub(add_to_list: lyris_error_response)

      Exceptional::Catcher.should_receive(:handle)

      Lyris::UserService.add_to_lyris(23, 'lyris_user@exmaple.com', 'lyris vc')
    end
  end

  describe '#update_users_email' do
    it 'can update a users email address on the lyris list' do
      Lyris::User.should_receive(:new).with(
        Lyris::Config.instance,
        'lyris_user@exmaple.com',
        {new_email: 'new_lyris_user@exmaple.com'}
      ).and_return(lyris_user_double)
      lyris_user_double.should_receive(:update_email).and_return(lyris_success_response)

      Lyris::UserService.update_users_email('lyris_user@exmaple.com', 'new_lyris_user@exmaple.com')
    end

    it 'sends errors to Exceptional in production' do
      Rails.env.stub(:production?).and_return(true)
      Lyris::UserDataCollector.stub(new: user_data)
      Lyris::User.stub(new: lyris_user_double)
      lyris_user_double.stub(update_email: lyris_error_response)

      Exceptional::Catcher.should_receive(:handle)

      Lyris::UserService.update_users_email('lyris_user@exmaple.com', 'new_lyris_user@exmaple.com')
    end
  end
end
