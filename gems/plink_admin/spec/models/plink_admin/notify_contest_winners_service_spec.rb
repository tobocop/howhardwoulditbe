require 'spec_helper'

describe PlinkAdmin::NotifyContestWinnersService do
  describe '.notify!' do
    let(:gigya) { double(Gigya, set_facebook_status: true) }
    let(:winner) { double(Plink::ContestWinnerRecord, user_id: 3) }
    let(:winners) { [winner, winner] }

    subject(:notify!) { PlinkAdmin::NotifyContestWinnersService.notify!(1, 'something') }

    before do
      Gigya.stub(:new).and_return(gigya)
      Plink::ContestWinnerRecord.stub(:to_notify_by_contest_id).and_return(winners)
      PlinkAdmin::NotifyContestWinnersService.stub(:contest_referral_url).and_return('a url')
    end

    it 'gets a gigya object with the gigya config' do
      Gigya.should_receive(:new).with(Gigya::Config.instance).and_return(gigya)

      notify!
    end

    it 'gets the contest winners by contest_id' do
      Plink::ContestWinnerRecord.should_receive(:to_notify_by_contest_id).with(1).and_return(winners)

      notify!
    end

    it 'posts to facebook for each winner' do
      gigya.should_receive(:set_facebook_status).
        with(3, 'something #Plink a url/facebook_winning_entry_post').
        exactly(2).times

      notify!
    end
  end
end
