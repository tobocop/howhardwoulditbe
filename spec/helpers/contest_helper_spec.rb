require 'spec_helper'

describe ContestHelper do
  describe '#entries_subtext' do
    it 'returns the correct text for enter_tomorrow' do
      text = 'Limit one share per social network per day'

      helper.entries_subtext('enter_tomorrow', 1).should == text
    end

    it 'returns the correct text for share_on_facebook' do
      text = 'Get 1 entry when you share on Facebook'

      helper.entries_subtext('share_on_facebook', 1).should == text
    end

    it 'returns the correct text for share_on_twitter' do
      text = 'Get 1 entry when you share on Twitter'

      helper.entries_subtext('share_on_twitter', 1).should == text
    end

    it 'returns the correct text for share_to_enter' do
      text = 'Get 2 entries when you share on Facebook and Twitter'

      helper.entries_subtext('share_to_enter', 2).should == text
    end
  end

  describe '#build_entries_statement' do
    let(:zoot_suit) { 'zoot suit network' }

    it 'displays the singular "entry" when there is 1 entry' do
      text = 'Get 1 entry when you share on zoot suit networks'

      helper.build_entries_statement(1, zoot_suit).should include
    end

    it 'displays the plural "entries" when there are 13 entries' do
      text = 'Get 1 entry when you share on zoot suit networks'

      helper.build_entries_statement(13, zoot_suit).should include
    end
  end

  describe '#groups_for_number_of_winners' do
    it 'raises an ArgumentError when given nil' do
      expect {
        helper.groups_for_number_of_winners(nil)
      }.to raise_error ArgumentError
    end

    it 'returns 8 if given 16 or less' do
      helper.groups_for_number_of_winners(16).should == 8
    end

    it 'returns 10 otherwise' do
      helper.groups_for_number_of_winners(17).should == 10
    end
  end
end
