class ContestNotificationPresenter

  attr_reader :contest, :dollars, :partial, :points, :user_id

  def initialize(attributes={})
    @affiliate_id = attributes[:affiliate_id] || Rails.application.config.default_contest_affiliate_id
    @contest = attributes[:contest]
    @dollars = attributes[:dollars]
    @partial = attributes[:partial]
    @points = attributes[:points]
    @user_id = attributes[:user_id]
  end

  delegate :entry_notification, :id, :prize, :winning_post_body, :winning_post_title, to: :contest

  def prize_with_article
    set_indefinite_article(prize)
  end

  def contest_share_url
    ContestPresenter.new(user_id: user_id, affiliate_id: @affiliate_id, contest: contest).
      share_link
  end

  def winner_share_data
    {
      'title' => winning_post_title,
      'description' => winning_post_body,
      'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
      'twitter-link' => "#{contest_share_url}/twitter_winning_entry_post",
      'facebook-link' => "#{contest_share_url}/facebook_winning_entry_post",
      'contest-winner-share-widget' => true
    }
  end

private

  def set_indefinite_article(word)
    %w(a e i o u).include?(word[0].downcase) ? "an #{word}" : "a #{word}"
  end
end
