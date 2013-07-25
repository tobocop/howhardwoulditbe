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
  end
end