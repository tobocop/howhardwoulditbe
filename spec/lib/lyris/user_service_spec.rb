require 'spec_helper'

describe Lyris::UserService do
  let(:user_data) { {my_data: 'derp'} }
  let(:lyris_user_double) { double(add_to_list: true) }
  let(:lyris_success_response) { double(successful?: true, data: 'email added') }
  let(:lyris_error_response) { double(successful?: false, data: 'email could not be added') }

  describe '#add_to_lyris' do
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
      module Exceptional ; class Catcher ; end ; end

      Rails.env.stub(:production?).and_return(true)

      Exceptional::Catcher.should_receive(:handle)

      Lyris::UserDataCollector.stub(new: user_data)
      Lyris::User.stub(new: lyris_user_double)
      lyris_user_double.stub(add_to_list: lyris_error_response)

      Lyris::UserService.add_to_lyris(23, 'lyris_user@exmaple.com', 'lyris vc')
    end
  end
end
