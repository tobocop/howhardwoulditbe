class LandingPagePresenter
  attr_reader :landing_page, :user_has_account

  def initialize(landing_page, user_has_account)
    @landing_page = landing_page
    @user_has_account = user_has_account
  end

  delegate :background_image_url, to: :landing_page

  def logged_in_action_button
    if user_has_account
      "<a href='#{Rails.application.routes.url_helpers.wallet_path}' class='button primary-action large'>Go to my wallet</a>".html_safe
    else
      "<a href='#{Rails.application.routes.url_helpers.institution_search_path}' class='button primary-action large'>Link my card</a>".html_safe
    end
  end

  def logged_out_action_button
    "<a href='#' class='button primary-action large' data-reveal-id='registration-form'>#{landing_page.button_text_one}</a>".html_safe
  end

  def partial
    landing_page.cms? ? 'cms' : landing_page.partial_path
  end

  def header
    inner_text = generate_inner_text(
      [
        landing_page.header_text_one,
        landing_page.header_text_two
      ]
    )
    "<h1 style='#{landing_page.header_text_styles}'>#{inner_text}</h1>".html_safe
  end

  def sub_header
    inner_text = generate_inner_text(
      [
        landing_page.sub_header_text_one,
        landing_page.sub_header_text_two
      ]
    )
    "<h2 class='light' style='#{landing_page.sub_header_text_styles}'>#{inner_text}</h2>".html_safe
  end

  def details
    inner_text = generate_inner_text(
      [
        landing_page.detail_text_one,
        landing_page.detail_text_two,
        landing_page.detail_text_three,
        landing_page.detail_text_four
      ]
    )
    "<div class='offer-details' style='#{landing_page.detail_text_styles}'>#{inner_text}</div>".html_safe
  end

  def how_plink_works_left
    inner_text = generate_inner_text(
      [
        landing_page.how_plink_works_one_text_one,
        landing_page.how_plink_works_one_text_two,
        landing_page.how_plink_works_one_text_three
      ]
    )
    "<h4 style='#{landing_page.how_plink_works_one_text_styles}'>#{inner_text}</h4>".html_safe
  end

  def how_plink_works_center
    inner_text = generate_inner_text(
      [
        landing_page.how_plink_works_two_text_one,
        landing_page.how_plink_works_two_text_two,
        landing_page.how_plink_works_two_text_three
      ]
    )
    "<h4 style='#{landing_page.how_plink_works_two_text_styles}'>#{inner_text}</h4>".html_safe
  end

  def how_plink_works_right
    inner_text = generate_inner_text(
      [
        landing_page.how_plink_works_three_text_one,
        landing_page.how_plink_works_three_text_two,
        landing_page.how_plink_works_three_text_three
      ]
    )
    "<h4 style='#{landing_page.how_plink_works_three_text_styles}'>#{inner_text}</h4>".html_safe
  end

private

  def generate_inner_text(array_of_strings)
    array_of_strings.reject(&:blank?).join('<br />')
  end
end
