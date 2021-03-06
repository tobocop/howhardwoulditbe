require 'spec_helper'

describe Plink::TangoTrackingRecord do

  it { should allow_mass_assignment_of(:card_number) }
  it { should allow_mass_assignment_of(:card_pin) }
  it { should allow_mass_assignment_of(:card_sku) }
  it { should allow_mass_assignment_of(:card_token) }
  it { should allow_mass_assignment_of(:card_value) }
  it { should allow_mass_assignment_of(:loot_id) }
  it { should allow_mass_assignment_of(:raw_response) }
  it { should allow_mass_assignment_of(:recipient_email) }
  it { should allow_mass_assignment_of(:recipient_name) }
  it { should allow_mass_assignment_of(:reference_order_id) }
  it { should allow_mass_assignment_of(:response_from_tango_on) }
  it { should allow_mass_assignment_of(:response_type) }
  it { should allow_mass_assignment_of(:sent_to_tango_on) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      user_id: 1,
      loot_id: 1,
      card_sku: 'comicsans',
      card_value: 10.00,
      recipient_name: 'Withakay Hicksville',
      recipient_email: 'fontboy@example.com',
      sent_to_tango_on: 1.hour.ago,
      response_from_tango_on: 10.minutes.ago,
      response_type: 'SUCCESS',
      reference_order_id: '113-083455456-28',
      card_token: '521e2ff4e536f9.10721055',
      card_number: 'V332-AM0ABN-WYZR',
      card_pin: 'wingdings'
    }
  }

  subject { Plink::TangoTrackingRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::TangoTrackingRecord.create(valid_params).should be_persisted
  end

  context 'scopes' do
    describe '.from_past_day' do
      let!(:tango_tracking_record) { create_tango_tracking(sent_to_tango_on: Time.zone.now) }

      subject(:from_past_day) { Plink::TangoTrackingRecord.from_past_day }

      it 'returns records that have been sent to tango within the past day' do
        from_past_day.should == [tango_tracking_record]
      end

      it 'does not return records sent to tango earlier then the past day' do
        tango_tracking_record.update_attribute('sentToTangoOn', 2.days.ago)

        from_past_day.should == []
      end
    end
  end
end
