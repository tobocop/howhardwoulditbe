require 'spec_helper'

describe Lyris::User do
  let(:lyris_config) {Lyris::Config.instance}
  let(:email) { 'toby@testing.com' }
  let(:valid_data) {
    {
      bank_registered: true,
      birthday: 10.years.ago.to_date,
      first_name: 'toby',
      gender: 'Male',
      incentivized_on_card_reg: true,
      incentivized_on_join: true,
      is_subscribed: true,
      last_name: 'derpston',
      login_token: 'HASHYMYAWESOME',
      registration_affiliate_id: 2,
      registration_date: 1.day.ago.to_date,
      state: 'CO',
      user_id: 382,
      virtual_currency: 'Plink Points',
      zip: 80204
    }
  }

  subject(:lyris_user) {Lyris::User.new(lyris_config, email, valid_data)}

  it 'can be initialized with an email and all necessary demographic data' do
    lyris_user.bank_registered.should == true
    lyris_user.birthday.should == 10.years.ago.to_date
    lyris_user.config.should == lyris_config
    lyris_user.first_name.should == 'toby'
    lyris_user.gender.should == 'Male'
    lyris_user.incentivized_on_card_reg.should == true
    lyris_user.incentivized_on_join.should == true
    lyris_user.is_subscribed.should == true
    lyris_user.last_name.should == 'derpston'
    lyris_user.login_token.should == 'HASHYMYAWESOME'
    lyris_user.new_email.should be_nil
    lyris_user.registration_affiliate_id.should == 2
    lyris_user.registration_date.should == 1.day.ago.to_date
    lyris_user.state.should == 'CO'
    lyris_user.user_id_ends_with.should == '2'
    lyris_user.user_id.should == 382
    lyris_user.virtual_currency.should == 'Plink Points'
    lyris_user.zip.should == 80204
  end

  context 'api calls' do
    let(:valid_xml_response) {
      '<?xml version="1.0" encoding="iso-8859-1" ?><DATASET><TYPE>success</TYPE><DATA>978b2909bd</DATA></DATASET>'
    }
    let(:http_double) { double(perform_request: double(body: valid_xml_response)) }

    before do
      Lyris::User.any_instance.stub(demographic_xml: 'xml_data')
      Lyris::User.any_instance.stub(removal_xml: 'removal_xml')
      Lyris::User.any_instance.stub(email_update_xml: 'email_xml')
    end

    describe '#add_to_list' do
      it 'calls the lyris http object' do
        Lyris::Http.should_receive(:new).with(
          lyris_config,
          'record',
          'add',
          {
            email: 'toby@testing.com',
            additional_xml: 'xml_data'
          }
        ).and_return(http_double)
        http_double.should_receive(:perform_request)

        response = lyris_user.add_to_list
        response.should be_a Lyris::Response
      end
    end

    describe '#update' do
      it 'calls the lyris http object' do
        Lyris::Http.should_receive(:new).with(
          lyris_config,
          'record',
          'update',
          {
            email: 'toby@testing.com',
            additional_xml: 'xml_data'
          }
        ).and_return(http_double)
        http_double.should_receive(:perform_request)

        response = lyris_user.update
        response.should be_a Lyris::Response
      end
    end

    describe '#update_email' do
      it 'returns nil if no new e-mail is set' do
        lyris_user = Lyris::User.new(lyris_config, email, {})
        lyris_user.update_email.should be_nil
      end

      it 'calls the lyris http object' do
        Lyris::Http.should_receive(:new).with(
          lyris_config,
          'record',
          'update',
          {
            email: 'toby@testing.com',
            additional_xml: 'email_xml'
          }
        ).and_return(http_double)
        http_double.should_receive(:perform_request)

        lyris_user = Lyris::User.new(lyris_config, email, {new_email: 'email@plink.com'})
        response = lyris_user.update_email
        response.should be_a Lyris::Response
      end
    end

    describe '#remove_from_list' do
      it 'calls the lyris http object' do
        Lyris::Http.should_receive(:new).with(
          lyris_config,
          'record',
          'update',
          {
            email: 'toby@testing.com',
            additional_xml: 'removal_xml'
          }
        ).and_return(http_double)
        http_double.should_receive(:perform_request)

        response = lyris_user.remove_from_list
        response.should be_a Lyris::Response
      end
    end
  end
end
