module FaqHelper
  def faq_items
    base = 'application.static_pages.faq.'
    {
      t(base + 'what_is_plink_title') => {answer: t(base + 'what_is_plink_text')},
      t(base + 'how_long_does_it_take_title') => {answer: t(base + 'how_long_does_it_take_text')},
      t(base + 'can_spouse_and_i_have_accounts_title') => {answer: t(base + 'can_spouse_and_i_have_accounts_text')},
      t(base + 'why_cant_i_find_my_bank_title') => {answer: t(base + 'why_cant_i_find_my_bank_text')},
      t(base + 'why_does_plink_need_my_login_title') => {answer: t(base + 'why_does_plink_need_my_login_text')},
      t(base + 'why_is_plink_safe_title') => {answer: t(base + 'why_is_plink_safe_text')},
      t(base + 'can_i_add_more_than_one_card_title') => {answer: t(base + 'can_i_add_more_than_one_card_text')},
      t(base + 'how_do_you_know_Ive_made_a_purchase_title') => {answer: t(base + 'how_do_you_know_Ive_made_a_purchase_text')},
      t(base + 'can_i_earn_rewards_multiple_time_title') => {answer: t(base + 'can_i_earn_rewards_multiple_time_text')},
      t(base + 'why_do_i_have_to_revalidate_title') => {answer: t(base + 'why_do_i_have_to_revalidate_text')},
      t(base + 'i_was_missing_points_title') => {answer: t(base + 'i_was_missing_points_text')},
      t(base + 'how_do_referrals_work_title') => {answer: t(base + 'how_do_referrals_work_text'), anchor_name: 'referral-program'},
      t(base + 'what_will_happen_if_i_return_title') => {answer: t(base + 'what_will_happen_if_i_return_text')},
      t(base + 'why_do_i_have_to_reverify_multiple_times_title') => {answer: t(base + 'why_do_i_have_to_reverify_multiple_times_text')},
      t(base + 'i_saw_promotion_for_a_brand_not_in_my_list_title') => {answer: t(base + 'i_saw_promotion_for_a_brand_not_in_my_list_text')},
      "I redeemed my points for a gift card, how and when will I receive it?" => {answer: "Most gift cards are sent via email within 24 - 48 hours of being ordered. Gift cards are sent from our gift card provider, Tango Card, or directly from the gift card carrier. If you've waited long a long time and still have not received your gift card, please contact us and we'd be happy to resend it."},
      "Is there a limit to how many times I can get double or triple points during the promotional period?" => {answer: "There is a limit to the number of bonus points you can get during a promotion. During any promotional period (from when it starts to the expiration date), you may earn up to 2500 bonus points, unless otherwise stated in the promotion. Please read the promotion details for each promotion to find out more."}
    }
  end
end
