shared_examples_for(:lyris_extensions) do
  let(:user_data) { {my_data: 'derp'} }
  let(:lyris_user_double) { double(add_to_list: true) }
  let(:successful_lyris_response) { double(successful?: true, data: 'email added') }
  let(:error_lyris_response) { double(successful?: false, data: 'email could not be added') }

  before do
    create_virtual_currency(name: 'lyris vc')
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
    lyris_user_double.should_receive(:add_to_list).and_return(successful_lyris_response)

    subject.add_to_lyris(23, 'lyris_user@exmaple.com')
  end

  it 'sends errors to Exceptional in production' do
    module Exceptional ; class Catcher ; end ; end

    Rails.env.stub(:production?).and_return(true)

    Exceptional::Catcher.should_receive(:handle)

    Lyris::UserDataCollector.stub(new: user_data)
    Lyris::User.stub(new: lyris_user_double)
    lyris_user_double.stub(add_to_list: error_lyris_response)

    subject.add_to_lyris(23, 'lyris_user@example.com')
  end
end

