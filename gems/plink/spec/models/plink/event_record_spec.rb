require 'spec_helper'

describe Plink::EventRecord do
  let(:valid_params) {
    {
      event_type_id: 1,
      user_id: 1,
      affiliate_id: 1,
      campaign_id: 2,
      sub_id: 'one',
      sub_id_two: 'two',
      sub_id_three: 'three',
      sub_id_four: 'four',
      path_id: 1,
      ip: '127.0.0.1',
      is_active: true
    }
  }

  subject {Plink::EventRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be created' do
    Plink::EventRecord.create(valid_params).should be_persisted
  end

end