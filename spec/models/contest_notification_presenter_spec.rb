require 'spec_helper'

describe ContestNotificationPresenter do
  let(:user) { create_user }
  let(:contest) {
    new_contest(
      description: 'This is a great description',
      image: '/assets/profile.jpg',
      non_linked_image: '/assets/another_image.jpg',
      prize: 'ipad',
      terms_and_conditions: 'This is a set of terms and conditions that apply to this contest specifically',
      winning_post_title: 'You won our sweet contest',
      winning_post_body: 'You won some stuff',
      entry_notification: 'Enter today or else...'
    )
  }

  let(:valid_params) {
    {
      contest: contest,
      dollars: 5,
      partial: 'enter_today',
      points: 500,
      user_id: user.id
    }
  }

  describe 'initialize' do
    it 'initializes with a contest notification object' do
      notification = ContestNotificationPresenter.new(valid_params)
      notification.user_id.should == user.id
    end
  end

  describe 'attributes' do
    it'should return the correct attributes' do
      presenter = ContestNotificationPresenter.new(valid_params)
      presenter.contest.should == contest
      presenter.dollars.should == 5
      presenter.id.should == contest.id
      presenter.partial.should == 'enter_today'
      presenter.points.should == 500
      presenter.prize.should == 'ipad'
      presenter.user_id.should == user.id
      presenter.entry_notification.should == 'Enter today or else...'
    end
  end

  describe 'prize_with_article' do
    it'should return the correct prize for the given contest_id with the correct indefinite article' do
      presenter = ContestNotificationPresenter.new(valid_params)
      presenter.prize_with_article.should == 'an ipad'

      contest.prize = 'house'
      presenter.prize_with_article.should == 'a house'
    end
  end

  describe 'contest_share_url' do
    let(:affiliate) { create_affiliate(id: 1431) }
    let(:contest) { create_contest }

    it'should generate a contest referral link' do
      share_link = "http://plink.test:58891/contest/refer/#{user.id}/aid/#{affiliate.id}/contest/#{contest.id}"
      presenter = ContestNotificationPresenter.new(valid_params)
      presenter.contest_share_url.should == share_link
    end
  end

  describe 'winner_share_data' do
    let(:contest) { create_contest }

    it 'returns a hash of share data for the contest winner' do
      presenter = ContestNotificationPresenter.new(valid_params)
      share_data = {
        'title' => contest.winning_post_title,
        'description' => contest.winning_post_body,
        'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
        'twitter-link' => "#{presenter.contest_share_url}/twitter_winning_entry_post",
        'facebook-link' => "#{presenter.contest_share_url}/facebook_winning_entry_post",
        'contest-winner-share-widget' => true
      }

      presenter.winner_share_data.should == share_data
    end
  end
end
