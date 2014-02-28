require 'spec_helper'

describe Plink::FreeAwardRecord do
  let(:valid_params) {
    {
        award_type_id: 1,
        currency_award_amount: 100,
        dollar_award_amount: 1,
        user_id: 1,
        is_active: true,
        users_virtual_currency_id: 1,
        virtual_currency_id: 1,
        is_successful: true,
        is_notification_successful: true
    }
  }

  subject { Plink::FreeAwardRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::FreeAwardRecord.create(valid_params).should be_persisted
  end

  describe 'named scopes' do
    describe '.awards_by_type_and_by_user_id' do
      let!(:free_award_record) { create_free_award(award_type_id: 3, user_id: 4, is_active: true) }

      subject(:awards_by_type_and_by_user_id) { Plink::FreeAwardRecord.awards_by_type_and_by_user_id(3,4) }

      it 'returns active records where the award type and user id match' do
        awards_by_type_and_by_user_id.length.should == 1
        awards_by_type_and_by_user_id.first.id.should == free_award_record.id
      end

      it 'does not return inactive records' do
        free_award_record.update_attribute('isActive', false)

        awards_by_type_and_by_user_id.length.should == 0
      end

      it 'does not return records that do not match the award type id' do
        free_award_record.update_attribute('awardTypeID', 2393)

        awards_by_type_and_by_user_id.length.should == 0
      end

      it 'does not return records that do not match the user_id' do
        free_award_record.update_attribute('userID', 387)

        awards_by_type_and_by_user_id.length.should == 0
      end
    end
  end
end
