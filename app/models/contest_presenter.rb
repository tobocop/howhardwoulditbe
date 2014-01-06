class ContestPresenter
  include ApplicationHelper

  attr_reader :contest, :user_id

  def initialize(attributes = {})
    @affiliate_id = attributes.fetch(:affiliate_id, Rails.application.config.default_contest_affiliate_id)
    @contest = attributes.fetch(:contest)
    @user_id = attributes[:user_id]
  end

  delegate :description, :end_time, :ended?, :entry_notification, :entry_post_body, :entry_post_title,
    :finalized?, :id, :image, :interstitial_body_text, :interstitial_bold_text, :interstitial_share_button,
    :interstitial_reg_link, :interstitial_title, :non_linked_image, :prize, :prize_description,
    :start_time, :started?, :terms_and_conditions, to: :contest

  def start_date
    start_time.strftime('%_m/%-d/%y')
  end

  def end_date
    end_time.strftime('%_m/%-d/%y')
  end

  def disabled_or_active_share_button(state)
    options = {id: 'js-share-to-enter', class: 'button primary-action'}

    if share_today?[state]
      options[:class] << ' white-txt'
      options[:data] = share_data(entry_providers[state])

      ActionController::Base.helpers.link_to entry_button_text(state), share_link, options
    else
      options[:class] << ' disabled'

      ActionController::Base.helpers.content_tag :a, entry_button_text(state), options
    end
  end

  def share_link
    Rails.application.routes.url_helpers.contest_referral_url(
      user_id: user_id,
      affiliate_id: @affiliate_id,
      contest_id: id,
    )
  end

  def share_data(providers)
    {
      'title' => entry_post_title,
      'description' => entry_post_body,
      'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
      'twitter-link' => "#{share_link}/twitter_entry_post",
      'facebook-link' => "#{share_link}/facebook_entry_post",
      'contest-share-widget' => true,
      'providers' => providers
    }
  end

  def social_referral_link(text)
    link_options = refer_a_friend({class: 'invite-friend-widget'})

    ActionController::Base.helpers.link_to text, social_referral_url, link_options
  end

  def social_referral_image(image_path)
    image_options = refer_a_friend({border: 0})
    image = ActionController::Base.helpers.image_tag(image_path, image_options)

    ActionController::Base.helpers.link_to image, social_referral_url, class: 'cyan'
  end

private

  def default_affiliate_id
    Rails.application.config.default_contest_affiliate_id
  end

  def refer_a_friend(options)
    user_id.present? ? options.merge!(data: refer_a_friend_data) : options
  end

  def entry_providers
    {
      'share_to_enter'    => 'facebook,twitter',
      'share_on_twitter'  => 'twitter',
      'share_on_facebook' => 'facebook'
    }
  end

  def share_today?
    {
      'share_to_enter' => true,
      'share_on_twitter' => true,
      'share_on_facebook' => true,
      'share_tomorrow' => false
    }
  end

  def social_referral_url
    if user_id.present?
      Rails.application.routes.url_helpers.referrer_url(user_id: user_id, affiliate_id: default_affiliate_id)
    else
      faq_referral_path
    end
  end

  def entry_button_text(state)
    state.gsub('_', ' ')
  end
end
