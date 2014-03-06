require 'spec_helper'

describe Plink::TangoLimitService do

  subject(:tango_limit_service) { Plink::TangoLimitService }

  describe '.past_daily_limit?' do
    let(:tango_tracking_record) { double(Plink::TangoTrackingRecord, card_value: 13.45) }
    let(:tango_tracking_records) { [tango_tracking_record, tango_tracking_record] }

    before do
      Plink::TangoTrackingRecord.stub(:from_past_day).and_return(tango_tracking_records)
      tango_limit_service.stub(:calculate_total).and_return(2499)
    end

    it 'looks up the tracking records from the last day' do
      Plink::TangoTrackingRecord.should_receive(:from_past_day).and_return(tango_tracking_records)

      tango_limit_service.past_daily_limit?
    end

    it 'calculates the total redemptions for the past day' do
      tango_limit_service.should_receive(:calculate_total).with(tango_tracking_records)

      tango_limit_service.past_daily_limit?
    end

    context 'when the total is over the daily limit' do
      before { tango_limit_service.stub(:calculate_total).and_return(2501) }

      it 'returns true' do
        tango_limit_service.past_daily_limit?.should be_true
      end
    end

    context 'when the total is under the daily limit' do
      before { tango_limit_service.stub(:calculate_total).and_return(2499) }

      it 'returns false' do
        tango_limit_service.past_daily_limit?.should be_false
      end
    end
  end
end
