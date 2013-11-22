require 'spec_helper'

describe Plink::AwardRecord  do
  it { should allow_mass_assignment_of(:email_message) }

  let(:award_type) { create_award_type(award_type: 'Bananas are awesome')}
  let!(:free_award) {
    create_free_award(
      award_type_id: award_type.id,
      currency_award_amount: 0,
      dollar_award_amount: 1,
      user_id: 2
    )
  }

  it 'returns the values from the view' do
    advertiser = create_advertiser
    create_qualifying_award(advertiser_id: advertiser.id)
    create_non_qualifying_award(advertiser_id: advertiser.id)

    Plink::AwardRecord.all.length.should == 3
  end

  it 'can return individual awards' do
    award_record = Plink::AwardRecord.first
    award_record.advertiser_name.should be_nil
    award_record.award_type.should == 'Bananas are awesome'
    award_record.currency_award_amount.should == 0
    award_record.dollar_award_amount.should == 1
    award_record.free_award_id.should == free_award.id
    award_record.non_qualifying_award_id.should be_nil
    award_record.qualifying_award_id.should be_nil
    award_record.user_id.should == 2
  end

  describe '#award_display_name' do
    it 'returns visiting advertiser_name if the advertiser_name is not blank' do
      award_record = Plink::AwardRecord.new(advertiser_name: 'joe', award_type: "love's spelling")
      award_record.award_display_name.should == 'visiting joe'
    end

    it 'returns the email_message if advertiser_name is blank' do
      award_record = Plink::AwardRecord.new(advertiser_name: '', email_message: 'email_message')
      award_record.award_display_name.should == 'email_message'
    end
  end

  context 'scopes' do
    describe '.plink_point_awards_pending_notification' do
      let(:valid_params) {
        {
          award_type_id: award_type.id,
          currency_award_amount: 0,
          is_notification_successful: false,
          is_active: true,
          is_successful: true,
          virtual_currency_id: default_virtual_currency.id
        }
      }

      let!(:default_virtual_currency) { create_virtual_currency(subdomain: 'www') }
      let!(:swagbucks_virtual_currency) { create_virtual_currency(subdomain: 'swagbucks') }

      let!(:award_notification_true_award) { create_free_award(valid_params.merge(is_notification_successful: true)) }
      let!(:is_active_false_award) { create_free_award(valid_params.merge(is_active: false)) }
      let!(:successful_false_award) { create_free_award(valid_params.merge(is_successful: false)) }
      let!(:wrong_virtual_currency_award) { create_free_award(valid_params.merge(virtual_currency_id: swagbucks_virtual_currency.id)) }
      let!(:expected_award) { create_free_award(valid_params) }

      it 'returns the expected award' do
        award_records = Plink::AwardRecord.plink_point_awards_pending_notification
        award_records.length.should == 1
        award_records.first.free_award_id.should == expected_award.id
      end
    end
  end
end
