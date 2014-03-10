require 'spec_helper'

describe Plink::AwardLinkService do
  let(:award_link_record) {
    double(
      Plink::AwardLinkRecord,
      award_type_id: 3,
      dollar_award_amount: 2.34,
      end_date: 1.day.from_now,
      id: 3,
      start_date: 1.day.ago
    )
  }

  subject(:award_link_service) { Plink::AwardLinkService.new('asd', 234) }

  before do
    Plink::AwardLinkRecord.stub(:where).and_return([award_link_record])
  end

  describe 'initialize' do
    it 'looks up the award link record by url value' do
      Plink::AwardLinkRecord.should_receive(:where).with(url_value: 'asd').and_return([award_link_record])

      award_link_service.award_link_record.should == award_link_record
    end

    it 'sets a user_id' do
      award_link_service.user_id.should == 234
    end
  end

  describe '#track_click' do
    it 'creates an award_link_tracking_record' do
      Plink::AwardLinkClickRecord.should_receive(:create).with(award_link_id: 3, user_id: 234)

      award_link_service.track_click
    end
  end

  describe '#live?' do
    it 'returns true if the current date is between the award_link_record start and end date' do
      award_link_service.live?.should be_true
    end

    it 'returns false if the current date is not between the award_link_record start and end date' do
      award_link_record.stub(:end_date).and_return(1.day.ago)
      award_link_service.live?.should be_false
    end
  end

  describe '#award' do
    let(:free_award_service) { double(Plink::FreeAwardService, award_unique: true) }

    before do
      Plink::FreeAwardService.stub(:new).and_return(free_award_service)
    end

    it 'calls the free award service to award' do
      Plink::FreeAwardService.should_receive(:new).with(2.34).and_return(free_award_service)
      free_award_service.should_receive(:award_unique).with(234, 3)

      award_link_service.award
    end
  end
end
