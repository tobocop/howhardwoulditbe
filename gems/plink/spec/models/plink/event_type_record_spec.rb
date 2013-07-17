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
    it 'returns the string "userRegistration" for an email_event_type' do
      Plink::EventTypeRecord.email_capture_type.should == 'userRegistration'
    end

  end
end