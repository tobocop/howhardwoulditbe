module ContestHelper
  def contest_share_data(contest_share_link)
    {
      'title' => 'Claim your share of $1,000 in Gift Cards from Plink',
      'description' => "Enter the Plink $1,000 Giveaway and win your share of $1,000 in gift cards at places like Amazon.com, Target, Walmart and more!",
      'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
      'twitter-link' => "#{contest_share_link}/twitter_entry_post",
      'facebook-link' => "#{contest_share_link}/facebook_entry_post",
      'contest-share-widget' => true
    }
  end

  def disabled_or_active_share_button(state, contest_id, user_id)
    case state
    when 'share_to_enter', 'share_on_twitter', 'share_on_facebook'
      base_referral_url = contest_referral_url(user_id: user_id, affiliate_id: default_affiliate_id, contest_id: contest_id)
      options = {
        data: contest_share_data(base_referral_url),
        id: 'js-share-to-enter',
        class: 'button primary-action white-txt'
      }

      link_to entry_button_text(state), base_referral_url, options
    when 'enter_tomorrow'
      options = {class: 'button primary-action disabled', id: 'js-share-to-enter'}

      content_tag :a, entry_button_text(state), options
    end
  end

  def entry_button_text(share_state)
    share_state.gsub('_', ' ')
  end

  def entries_subtext(share_state, entries)
    if share_state == 'enter_tomorrow'
      'Limit one share per social network per day'
    else
      case share_state
      when 'share_to_enter'
        build_entries_statement(entries, 'Facebook and Twitter')
      when 'share_on_twitter'
        build_entries_statement(entries, 'Twitter')
      when'share_on_facebook'
        build_entries_statement(entries, 'Facebook')
      end
    end
  end

  def entry_or_entries(number)
    number == 1 ? 'entry' : 'entries'
  end

  def build_entries_statement(count, network_string)
    "Get #{count} #{entry_or_entries(count)} when you share on #{network_string}"
  end

  def contest_social_referral_link(text, user_id)
    url = contest_social_referral_url(user_id)
    options = merge_refer_a_friend({class: 'invite-friend-widget'}, user_id)

    link_to text, url, options
  end

  def contest_social_referral_image(image_path, user_id)
    url = contest_social_referral_url(user_id)
    options = merge_refer_a_friend({border: 0}, user_id)

    link_to image_tag(image_path, options), url, class: 'cyan'
  end

  def contest_social_referral_url(user_id)
    if user_id.present?
      referrer_url(user_id: user_id, affiliate_id: default_affiliate_id)
    else
      faq_referral_path
    end
  end

  def faq_referral_path
    faq_static_path(anchor: 'referral-program')
  end

  def contest_winner_share_data(contest_share_link, dollar_amount)
    {
      'title' => 'I just won a Plink contest! You can be a Winner, too.',
      'description' => "I just won $#{dollar_amount} in gift cards from Plink! Join Plink today and enter for your chance to win.",
      'image' => 'http://plink-images.s3.amazonaws.com/plink_logo/90x90.jpg',
      'twitter-link' => "#{contest_share_link}/twitter_winning_entry_post",
      'facebook-link' => "#{contest_share_link}/facebook_winning_entry_post",
      'contest-winner-share-widget' => true
    }
  end

  def contest_winner_share(contest_id, user_id, dollar_amount)
    base_referral_url = contest_referral_url(user_id: user_id, affiliate_id: default_affiliate_id, contest_id: contest_id)
    options = {
      data: contest_winner_share_data(base_referral_url, dollar_amount),
      class: 'button primary-action'
    }

    link_to 'Tell Your Friends', base_referral_url, options
  end

  def groups_for_number_of_winners(number_of_winners)
    raise ArgumentError if number_of_winners.blank?

    if number_of_winners <= 16
      8
    else
      10
    end
  end

private

  def default_affiliate_id
    Rails.application.config.default_contest_affiliate_id
  end

  def merge_refer_a_friend(options, user_id)
    user_id.present? ? options.merge!(data: refer_a_friend_data) : options
  end
end
