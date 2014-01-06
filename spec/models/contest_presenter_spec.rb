require 'spec_helper'

describe ContestPresenter do
  let(:user) { create_user }
  let(:start_time) { 3.days.ago }
  let(:end_time) { 6.days.from_now }
  let(:contest) {
    new_contest(
      description: 'This is a great description',
      end_time: end_time,
      image: '/assets/profile.jpg',
      non_linked_image: '/assets/another_image.jpg',
      prize: 'This is the prize - a brand new, shiny boat!',
      prize_description: 'the boat floats on water',
      start_time: start_time,
      terms_and_conditions: 'This is a set of terms and conditions that apply to this contest specifically'
    )
  }
  let(:valid_params) {
    {
      contest: contest,
      user_has_linked_card: true,
      user_is_logged_in: true,
      card_link_url: 'http://www.herp.derp.com'
    }
  }


  describe 'initialize' do
    it 'initializes with a contest object' do
      presenter = ContestPresenter.new(contest: contest, user_id: user.id)
      presenter.description.should == 'This is a great description'
    end
  end

  describe 'attributes' do
    it 'should return the correct attributes based on how it was initialized' do
      presenter = ContestPresenter.new(contest: contest, user_id: user.id)
      presenter.description.should == 'This is a great description'
      presenter.end_date.should == end_time.strftime('%_m/%-d/%y')
      presenter.ended?.should == false
      presenter.id.should == contest.id
      presenter.image.should == '/assets/profile.jpg'
      presenter.non_linked_image.should ==  '/assets/another_image.jpg'
      presenter.prize.should == 'This is the prize - a brand new, shiny boat!'
      presenter.prize_description.should == 'the boat floats on water'
      presenter.start_date.should == start_time.strftime('%_m/%-d/%y')
      presenter.started?.should == true
      presenter.terms_and_conditions.should == 'This is a set of terms and conditions that apply to this contest specifically'
      presenter.user_id.should == user.id
    end
  end

  describe 'disabled_or_active_share_button' do
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
      let(:contest) { create_contest }
      let(:presenter) { ContestPresenter.new(contest: contest, user_id: user.id) }

      it 'returns a contest referral link with "share to enter"' do
        contest_share = {'providers' => 'facebook,twitter'}
        presenter.disabled_or_active_share_button('share_to_enter').should =~ /share to enter/
      end
      it 'returns a link with "share on facebook" to the contest_id passed in' do
        contest_share = {'providers' => 'facebook'}
        presenter.disabled_or_active_share_button('share_on_facebook').should =~ /share on facebook/
      end
      it 'returns a link with "share on twitter" to the contest_id passed in' do
        contest_share = {'providers' => 'twitter'}
        presenter.disabled_or_active_share_button('share_on_twitter').should =~ /share on twitter/
      end
    end

    context 'without additional entry opportunities today' do
      let(:contest) { create_contest }
      it 'returns a link with the test Enter Tomorrow' do
        presenter = ContestPresenter.new(contest: contest, user_id: user.id)
        link = "<a class=\"button primary-action disabled\" id=\"js-share-to-enter\">enter tomorrow</a>"
        presenter.disabled_or_active_share_button('enter_tomorrow').should == link
      end
    end
  end

  describe 'share_data' do
    let(:contest) { create_contest }
    it 'returns a hash of share data' do
      presenter = ContestPresenter.new(contest: contest, user_id: user.id)
      share_data = {
        'title' => contest.entry_post_title,
        'description' => contest.entry_post_body,
        'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
        'twitter-link' => "http://plink.test:58891/contest/refer/#{user.id}/aid/1431/contest/#{contest.id}/twitter_entry_post",
        'facebook-link' => "http://plink.test:58891/contest/refer/#{user.id}/aid/1431/contest/#{contest.id}/facebook_entry_post",
        'contest-share-widget' => true,
        'providers' => 'this_is_a_provider'
      }

      presenter.share_data('this_is_a_provider').should == share_data
    end
  end

  describe 'share_link' do
    let(:user) { create_user }
    let!(:contest) { create_contest(id: 1) }
    let(:affiliate) { create_affiliate(id: 1431) }

    it 'generates a contest referral link' do
      share_link = "http://plink.test:58891/contest/refer/#{user.id}/aid/#{affiliate.id}/contest/#{contest.id}"
      presenter = ContestPresenter.new(contest: contest, user_id: user.id)
      presenter.share_link.should == share_link
    end
  end

  describe 'social_referral_image' do
    let(:presenter) { ContestPresenter.new(contest: contest, user_id: user.id) }

    it 'returns a link populated with the given image path, border of 0, and refer_a_friend_data' do
      presenter.social_referral_image('/assets/example.png').should =~ /class="cyan"><img alt="Example" border="0" data-description="Join Plink for free and get 300 bonus Plink Points if you sign up today and link a card. Earn the rewards you deserve every time you shop or dine out!" data-image="http:\/\/plink-images.s3.amazonaws.com\/plink_logo\/90x90.jpg" data-share-widget="true" data-title="Join Plink for free and receive 300 bonus points!" src="\/assets\/example.png" \/><\/a>/
    end
  end
end
