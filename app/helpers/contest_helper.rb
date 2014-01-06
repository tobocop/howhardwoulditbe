module ContestHelper
  def entries_subtext(share_state, entries)
    if share_state == 'enter_tomorrow'
      'Limit one share per social network per day'
    else
      case share_state
      when 'share_to_enter'
        build_entries_statement(entries, 'Facebook and Twitter')
      when 'share_on_twitter'
        build_entries_statement(entries, 'Twitter')
      when 'share_on_facebook'
        build_entries_statement(entries, 'Facebook')
      end
    end
  end

  def build_entries_statement(count, network_string)
    "Get #{pluralize(count, 'entry')} when you share on #{network_string}"
  end

  def faq_referral_path
    faq_static_path(anchor: 'referral-program')
  end

  def groups_for_number_of_winners(number_of_winners)
    raise ArgumentError if number_of_winners.blank?

    if number_of_winners <= 16
      8
    else
      10
    end
  end

  def entry_button_text(state)
    state.gsub('_', ' ')
  end
end
