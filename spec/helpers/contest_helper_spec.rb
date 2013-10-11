require 'spec_helper'

describe ContestHelper do
  describe '#contest_share_data' do
    it 'returns a hash with share data' do
      share_data = {
        'title' => t('application.contests.entry_post.title'),
        'description' => t('application.contests.entry_post.description'),
        'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
        'twitter-link' => 'http://example.com/twitter_entry_post',
        'facebook-link' => 'http://example.com/facebook_entry_post',
        'contest-share-widget' => true,
        'providers' => 'this_is_a_provider'
      }

      helper.contest_share_data('http://example.com', 'this_is_a_provider').should == share_data
    end
  end

  describe '#disabled_or_active_share_button' do
    let(:contest_data) {
      {
        'title' => '',
        'description' => '',
        'image' => '',
        'twitter-link' => 'twitter-link',
        'facebook-link' => 'facebook-link',
        'contest-share-widget' => true
      }
    }

    context 'with additional entry opportunities today' do
      let(:open_anchor_tag) { %Q[<a href="http://test.host/contest/refer/23/aid/1431/contest/2" class="button primary-action white-txt" data-contest-share-widget="true" data-description="" data-facebook-link="facebook-link" data-image="" data-title="" data-twitter-link="twitter-link" id="js-share-to-enter"] }

      it 'returns a contest referral link with "share to enter"' do
        contest_share = {'providers' => 'facebook,twitter'}
        helper.stub(:contest_share_data).and_return(contest_data.merge(contest_share))
        link = %Q[#{open_anchor_tag} data-providers="#{contest_share['providers']}">share to enter</a>]

        assert_dom_equal(link, helper.disabled_or_active_share_button('share_to_enter', 2, 23))
      end
      it 'returns a link with "share on facebook" to the contest_id passed in' do
        contest_share = {'providers' => 'facebook'}
        helper.stub(:contest_share_data).and_return(contest_data.merge(contest_share))
        link = %Q[#{open_anchor_tag} data-providers="#{contest_share['providers']}">share on facebook</a>]

        assert_dom_equal(link, helper.disabled_or_active_share_button('share_on_facebook', 2, 23))
      end
      it 'returns a link with "share on twitter" to the contest_id passed in' do
        contest_share = {'providers' => 'twitter'}
        helper.stub(:contest_share_data).and_return(contest_data.merge(contest_share))
        link = %Q[#{open_anchor_tag} data-providers="#{contest_share['providers']}">share on twitter</a>]

        assert_dom_equal(link, helper.disabled_or_active_share_button('share_on_twitter', 2, 23))
      end
    end

    context 'without additional entry opportunities today' do
      it 'returns a link with the test Enter Tomorrow' do
        link = "<a class=\"button primary-action disabled\" id=\"js-share-to-enter\">enter tomorrow</a>"
        assert_dom_equal(link, helper.disabled_or_active_share_button('enter_tomorrow', nil, nil))
      end
    end
  end

  describe '#entry_providers' do
    it 'returns facebook and twitter when given share_to_enter' do
      helper.entry_providers('share_to_enter').should == 'facebook,twitter'
    end
    it 'returns facebook and twitter when given share_on_facebook' do
      helper.entry_providers('share_on_facebook').should == 'facebook'
    end
    it 'returns twitter when given share_on_twitter' do
      helper.entry_providers('share_on_twitter').should == 'twitter'
    end
  end

  describe '#entry_button_text' do
    it 'removes underscores and replaces them with spaces' do
      helper.entry_button_text('this_is_text').should == 'this is text'
    end
  end

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

  describe '#contest_social_referral_link' do
    context 'with a user_id' do
      it 'returns a link populated with the given text, appropriate class, and refer_a_friend_data' do
        helper.stub(:refer_a_friend_data).and_return({
          'title' => 'title',
          'description' => 'description',
          'image' => 'image'
        })

        link = '<a href="http://test.host/refer/1/aid/1431" class="invite-friend-widget" data-title="title" data-description="description" data-image="image">given_text</a>'
        assert_dom_equal(link, helper.contest_social_referral_link('given_text', 1))
      end
    end

    context 'without a user_id' do
      it 'returns a link populated with the given text and appropriate class' do
        link = '<a href="/faq#referral-program" class="invite-friend-widget">given_text</a>'
        assert_dom_equal(link, helper.contest_social_referral_link('given_text', nil))
      end
    end
  end

  describe '#contest_social_referral_image' do
    context 'with a user_id' do
      it 'returns a link populated with the given image path, border of 0, and refer_a_friend_data' do
        helper.stub(:refer_a_friend_data).and_return({
          'title' => 'title',
          'description' => 'description',
          'image' => 'image'
        })

        link = '<a href="http://test.host/refer/1/aid/1431" class="cyan"><img alt="Example" border="0" data-description="description" data-image="image" data-title="title" src="/assets/example.png"/></a>'
        assert_dom_equal(link, helper.contest_social_referral_image('example.png', 1))
      end
    end

    context 'without a user_id' do
      it 'returns a link populated with the given text and appropriate class' do
        link = '<a href="/faq#referral-program" class="cyan"><img alt="Example" border="0" src="/assets/example.png"/></a>'
        assert_dom_equal(link, helper.contest_social_referral_image('example.png', nil))
      end
    end
  end

  describe '#contest_social_referral_url' do
    it 'returns a referral link when a user_id is present' do
      helper.contest_social_referral_url(150).should == 'http://test.host/refer/150/aid/1431'
    end

    it 'returns a link to the referral section of the FAQ when a user_id is not present' do
      helper.contest_social_referral_url(nil).should == '/faq#referral-program'
    end
  end

  describe '#contest_winner_share_data' do
    it 'returns a hash with share data for the contest winner' do
      share_data = {
        'title' => t('application.contests.winners_post.title'),
        'description' => t('application.contests.winners_post.description'),
        'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
        'twitter-link' => "http://example.com/twitter_winning_entry_post",
        'facebook-link' => "http://example.com/facebook_winning_entry_post",
        'contest-winner-share-widget' => true
      }

      helper.contest_winner_share_data('http://example.com', 10).should == share_data
    end
  end

  describe '#contest_winner_share' do
    let(:anchor_tag) { "<a href=\"http://test.host/contest/refer/23/aid/1431/contest/1\" class=\"button primary-action\" data-contest-winner-share-widget=\"true\" data-description=\"\" data-facebook-link=\"facebook-link\" data-image=\"\" data-title=\"\" data-twitter-link=\"twitter-link\">Tell Your Friends</a>"}

    before do
      helper.stub(:contest_winner_share_data).and_return({
        'title' => '',
        'description' => '',
        'image' => '',
        'twitter-link' => 'twitter-link',
        'facebook-link' => 'facebook-link',
        'contest-winner-share-widget' => true
      })
    end

    it 'returns a contest share link' do
      link = "#{anchor_tag}</a>"
      assert_dom_equal(link, helper.contest_winner_share(1,23,3))
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
