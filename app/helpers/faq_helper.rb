module FaqHelper
  def faq_items
    base = 'application.static_pages.faq.'
    {
      t(base + 'what_is_plink_title') => {answer: t(base + 'what_is_plink_text')},
      t(base + 'what_is_a_qualified_purchase_title') => {answer: t(base + 'what_is_a_qualified_purchase_text')},
      t(base + 'how_long_does_it_take_title') => {answer: t(base + 'how_long_does_it_take_text')},
      t(base + 'what_if_i_dont_get_my_points_title') => {answer: t(base+ 'what_if_i_dont_get_my_points_text')},
      t(base + 'can_spouse_and_i_have_accounts_title') => {answer: t(base + 'can_spouse_and_i_have_accounts_text')},
      t(base + 'why_cant_i_find_my_bank_title') => {answer: t(base + 'why_cant_i_find_my_bank_text')},
      t(base + 'why_does_plink_need_my_login_title') => {answer: t(base + 'why_does_plink_need_my_login_text')},
      t(base + 'my_login_credentials_are_invalid_title') => {answer: t(base + 'my_login_credentials_are_invalid_text')},
      t(base + 'why_is_plink_safe_title') => {answer: t(base + 'why_is_plink_safe_text')},
      t(base + 'can_i_add_more_than_one_card_title') => {answer: t(base + 'can_i_add_more_than_one_card_text')},
      t(base + 'will_i_get_points_if_i_change_card_title') => {answer: t(base + 'will_i_get_points_if_i_change_card_text')},
      t(base + 'how_do_you_know_Ive_made_a_purchase_title') => {answer: t(base + 'how_do_you_know_Ive_made_a_purchase_text')},
      t(base + 'can_i_earn_rewards_multiple_time_title') => {answer: t(base + 'can_i_earn_rewards_multiple_time_text')},
      t(base + 'why_do_i_have_to_revalidate_title') => {answer: t(base + 'why_do_i_have_to_revalidate_text')},
      t(base + 'what_if_i_dont_revalidate_title') => {answer: t(base + 'what_if_i_dont_revalidate_text')},
      t(base + 'i_was_missing_points_title') => {answer: t(base + 'i_was_missing_points_text')},
      t(base + 'how_do_referrals_work_title') => {answer: t(base + 'how_do_referrals_work_text'), anchor_name: 'referral-program'},
      t(base + 'what_will_happen_if_i_return_title') => {answer: t(base + 'what_will_happen_if_i_return_text')},
      t(base + 'why_do_i_have_to_reverify_multiple_times_title') => {answer: t(base + 'why_do_i_have_to_reverify_multiple_times_text')},
      t(base + 'i_saw_promotion_for_a_brand_not_in_my_list_title') => {answer: t(base + 'i_saw_promotion_for_a_brand_not_in_my_list_text')},
      t(base + 'how_do_i_receive_gift_cards_title') => {answer: t(base + 'how_do_i_receive_gift_cards_text')},
      t(base + 'is_there_a_double_points_limit_title') => {answer: t(base + 'is_there_a_double_points_limit_text')}
    }
  end
end
