require 'spec_helper'

describe EntriesPresenter do
  let(:facebook_entry) { create_entry(provider: 'facebook', computed_entries: 2) }
  let(:twitter_entry) { create_entry(provider: 'twitter', computed_entries: 13) }

  describe '.share_state' do
    it 'returns "share_to_enter" if no providers have been shared today' do
      presenter = EntriesPresenter.new([])
      presenter.share_state.should == 'share_to_enter'
    end

    it 'returns "enter_tomorrow" if all providers have been shared today' do
      presenter = EntriesPresenter.new([facebook_entry, twitter_entry])
      presenter.share_state.should == 'enter_tomorrow'
    end

    it 'returns "share_on_twitter" if facebook has been shared today' do
      presenter = EntriesPresenter.new([facebook_entry])
      presenter.share_state.should == 'share_on_twitter'
    end

    it 'returns "share_on_facebook" if twitter has been shared today' do
      presenter = EntriesPresenter.new([twitter_entry])
      presenter.share_state.should == 'share_on_facebook'
    end
  end

  describe '.unshared_provider_count' do
    it 'returns 2 if no provider has been shared on' do
      presenter = EntriesPresenter.new([])

      presenter.unshared_provider_count.should == 2
    end

    it 'returns 1 if only 1 provider has been shared on' do
      presenter = EntriesPresenter.new([facebook_entry])
      presenter.unshared_provider_count.should == 1

      presenter = EntriesPresenter.new([twitter_entry])
      presenter.unshared_provider_count.should == 1
    end

    it 'returns 0 if both providers have been shared on' do
      presenter = EntriesPresenter.new([facebook_entry, twitter_entry])

      presenter.unshared_provider_count.should == 0
    end
  end

end
