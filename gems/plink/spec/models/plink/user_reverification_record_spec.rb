require 'spec_helper'

describe Plink::UserReverificationRecord do
  let(:valid_params) {
    {
      user_id: 1,
      users_institution_id: 1,
      users_intuit_error_id: 1,
      completed_on: nil,
      is_active: true
    }
  }

  subject {Plink::UserReverificationRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::UserReverificationRecord.create(valid_params).should be_persisted
  end


  describe 'incomplete' do
    before do
      create_user_reverification(completed_on: Time.zone.today, is_active: true)
      @expected = create_user_reverification(completed_on: nil, is_active: true)
      create_user_reverification(completed_on: Time.zone.today, is_active: false)
      create_user_reverification(completed_on: nil, is_active: false)
    end

    it 'returns active and not completed reverification records' do
      reverifications = Plink::UserReverificationRecord.incomplete
      reverifications.length.should == 1
      reverifications.should include @expected
    end
  end
end
