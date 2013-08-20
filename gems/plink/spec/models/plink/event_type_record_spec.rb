require 'spec_helper'

describe Plink::EventTypeRecord do
  let(:valid_params) {
    {
      name: 'Foo'
    }
  }

  subject { Plink::EventTypeRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::EventTypeRecord.create(valid_params).should be_persisted
  end

  it 'returns an event type record by an event type' do
    event_type = create_event_type(valid_params)
    Plink::EventTypeRecord.for_name('Foo').should == event_type
  end

  context 'types' do
    it 'returns the string "userRegistration" for email_type' do
      Plink::EventTypeRecord.email_capture_type.should == 'userRegistration'
    end

    it 'returns the string "impression" for impression_type' do
      Plink::EventTypeRecord.impression_type.should == 'impression'
    end

    it 'returns the string "login" for login_type' do
      Plink::EventTypeRecord.login_type.should == 'login'
    end

    it 'returns the string "credentialRegistration" for card_add_type' do
      Plink::EventTypeRecord.card_add_type.should == 'credentialRegistration'
    end

    it 'returns the string "cardChange" for card_change_type' do
      Plink::EventTypeRecord.card_change_type.should == 'cardChange'
    end

    it 'returns the string "facebookLogin" for facebook_login_type' do
      Plink::EventTypeRecord.facebook_login_type.should == 'facebookLogin'
    end

    it 'returns the string "offerWallActivate" for offer_activate_type' do
      Plink::EventTypeRecord.offer_activate_type.should == 'offerWallActivate'
    end

    it 'returns the string "offerWallDeactivate" for offer_deactivate_type' do
      Plink::EventTypeRecord.offer_deactivate_type.should == 'offerWallDeactivate'
    end
  end
end
