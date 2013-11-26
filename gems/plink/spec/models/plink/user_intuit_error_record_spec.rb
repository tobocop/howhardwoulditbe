require 'spec_helper'

describe Plink::UserIntuitErrorRecord do
  it { should allow_mass_assignment_of(:intuit_error_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params){
    {
      intuit_error_id: 1,
      users_institution_id: 234,
      user_id: 14
    }
  }

  it 'can be persisted' do
    Plink::UserIntuitErrorRecord.create(valid_params).should be_persisted
  end

  context 'named scopes' do
    describe '.errors_that_require_attention' do
      it 'returns all errors that require immediate attention and errors that have happened consecutively for five days' do
        Plink::UserIntuitErrorRecord.immediate_attention_error_codes.each do |error_code|
          create_user_intuit_error(intuit_error_id: error_code, created: Time.zone.now)
          create_user_intuit_error(intuit_error_id: error_code * 100, created: Time.zone.now)
        end

        Plink::UserIntuitErrorRecord.five_day_error_codes.each do |error_code|
          past_days = 1..5
          past_days.each do |past_day|
            create_user_intuit_error(intuit_error_id: error_code, created: (past_day + 10).days.ago)
            create_user_intuit_error(intuit_error_id: error_code, created: past_day.days.ago)
            create_user_intuit_error(intuit_error_id: error_code * 100, created: past_day.days.ago)
          end
        end

        Plink::UserIntuitErrorRecord.errors_that_require_attention.length.should == 6
      end
    end

    describe '.errors_that_require_immediate_attention' do
      let(:errors_that_require_immediate_attention) { Plink::UserIntuitErrorRecord.errors_that_require_immediate_attention }

      before do
        Plink::UserIntuitErrorRecord.immediate_attention_error_codes.each do |error_code|
          create_user_intuit_error(intuit_error_id: error_code, created: Time.zone.now)
          create_user_intuit_error(intuit_error_id: error_code * 100, created: Time.zone.now)
        end
      end

      it 'returns records that have an error code in IMMEDIATE_ATTENTION_ERROR_CODES' do
        errors_that_require_immediate_attention.length.should == 4
      end

      it 'does not return records created before today' do
        create_user_intuit_error(intuit_error_id: 103, created: 1.day.ago)
        errors_that_require_immediate_attention.length.should == 4
      end
    end

    describe 'errors_occuring_five_consecutive_days' do
      let(:errors_occuring_five_consecutive_days) { Plink::UserIntuitErrorRecord.errors_occuring_five_consecutive_days }

      before do
        Plink::UserIntuitErrorRecord.five_day_error_codes.each do |error_code|
          past_days = 1..4
          past_days.each do |past_day|
            create_user_intuit_error(intuit_error_id: error_code, created: (past_day + 10).days.ago)
            create_user_intuit_error(intuit_error_id: error_code, created: past_day.days.ago)
            create_user_intuit_error(intuit_error_id: error_code * 100, created: past_day.days.ago)
          end
        end
      end

      it 'returns the most recently created records that have an error code in FIVE_DAY_ERROR_CODES' do
        first_code = create_user_intuit_error(intuit_error_id: 185, created: 5.days.ago)
        second_code = create_user_intuit_error(intuit_error_id: 187, created: 5.days.ago)

        errors = errors_occuring_five_consecutive_days.all
        errors.length.should == 2
        errors.map(&:id).should =~ [first_code.id, second_code.id]
      end

      it 'does not return records created more then 5 days ago' do
        create_user_intuit_error(intuit_error_id: 185, created: 6.days.ago)
        create_user_intuit_error(intuit_error_id: 187, created: 5.days.ago)
        errors_occuring_five_consecutive_days.length.should == 1
      end

      it 'does not return records with only 4 entries in 5 days' do
        create_user_intuit_error(intuit_error_id: 187, created: 5.days.ago)
        errors_occuring_five_consecutive_days.length.should == 1
      end
    end
  end

  describe '.immediate_attention_error_codes' do
    it 'returns the array of error codes we need to take immediate action on' do
      error_codes = [103, 106, 108, 109]
      Plink::UserIntuitErrorRecord.immediate_attention_error_codes.should == error_codes
    end
  end

  describe '.five_day_error_codes' do
    it 'returns the array of error codes we need to wait until we have 5 failures on' do
      error_codes = [185, 187]
      Plink::UserIntuitErrorRecord.five_day_error_codes.should == error_codes
    end
  end
end
