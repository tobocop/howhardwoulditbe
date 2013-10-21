require 'spec_helper'

describe 'guest behavior' do
  before do
    currency = create_virtual_currency(name: 'Plink Points', subdomain: Plink::VirtualCurrency::DEFAULT_SUBDOMAIN)

    advertiser = create_advertiser(advertiser_name: 'Old Nervy', logo_url: '/assets/test/oldnavy.png')

    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)

    create_offer(
      advertiser_id: advertiser.id,
      detail_text: 'great deal',
      offers_virtual_currencies: [
        new_offers_virtual_currency(
          virtual_currency_id: currency.id,
          tiers: [
            new_tier(
              dollar_award_amount: 0.43
            ),
            new_tier(
              dollar_award_amount: 1.43
            )
          ]
        )
      ]
    )

    create_reward(name: 'Walmart Gift Card', amounts:
      [
        new_reward_amount(dollar_award_amount: 5, is_active: true),
        new_reward_amount(dollar_award_amount: 10, is_active: true),
        new_reward_amount(dollar_award_amount: 15, is_active: false),
        new_reward_amount(dollar_award_amount: 25, is_active: true),
        new_reward_amount(dollar_award_amount: 50, is_active: true)
      ]
    )

    create_reward(name: 'Should Not Exist Gift Card', is_active: false, amounts:
      [
        new_reward_amount(dollar_award_amount: 5, is_active: true)
      ]
    )
  end

  it 'should check the reset password form for errors' do
    visit new_password_reset_request_path
    click_on 'Send Password Reset Instructions'

    page.should have_text "An email with instructions to reset your password has been sent to the email address provided.  If you don't receive an email within the hour, please contact our member support."

    visit new_password_reset_request_path
    fill_in 'Email', with: 'notamember@Plink.com'
    click_on 'Send Password Reset Instructions'
    page.should have_text "An email with instructions to reset your password has been sent to the email address provided.  If you don't receive an email within the hour, please contact our member support."

  end

  it 'user workflow when logged out', js: true do
    visit '/'

    page.should have_css '[gigid="showShareBarUI"]'


    within '.feature' do
      page.should have_content 'Join Plink for FREE'
      page.should have_css '[data-reveal-id="registration-form"]'
    end

    within '.security' do
      page.should have_content 'Join Plink for FREE'
      page.should have_css '[data-reveal-id="registration-form"]'
    end

    page.first("a", text: "Contact Us").click

    click_button 'Submit'

    page.should have_content 'Please provide your first name'
    page.should have_content 'Please provide your last name'
    page.should have_content 'Please provide your Plink registered email'

    fill_in 'First Name', with: 'Bob'
    fill_in 'Last Name', with: 'Jones'
    fill_in 'Email', with: 'bob@example.com'

    page.should have_checked_field 'Customer Support'
    page.should have_unchecked_field 'Other'
    page.should have_unchecked_field 'Advertising and Business Development'
    page.should have_unchecked_field 'Investor Relations'

    choose 'Advertising and Business Development'

    fill_in 'contact_form[message_text]', with: 'Some message'

    click_button 'Submit'

    page.should have_content 'Thank you for contacting Plink.'

    ActionMailer::Base.deliveries.count.should == 1

    contact_email = ActionMailer::Base.deliveries.first
    contact_email.subject.should == 'Contact Form: [Advertising and Business Development]'

    visit '/rewards'

    page.should have_image('icon_lock')

    page.should have_text "Planning on having enough points for a larger gift card?"

    page.should have_content 'Walmart Gift Card'
    page.should have_content '$5'
    page.should have_content '$10'
    page.should_not have_content '$15'

    within '.denomination.locked', match: :first do
      page.should_not have_content '$25'
      page.should have_content '$50'
    end

    page.should_not have_content 'Should Not Exist Gift Card'

    visit '/'

    click_on 'See all of our rewards'
    page.should have_content 'CHOOSE YOUR REWARD'
    page.should have_css('img[src="/assets/test/amazon.png"]')
    find(".header-logo").click


    click_on 'See all of our partners'

    page.should have_content 'Earn Plink Points at these locations.'
    page.should have_css('img[src="/assets/test/oldnavy.png"]')
    page.should have_content '143 Plink Points'

    within '.offer' do
      click_button 'Details'
    end

    click_on 'Join Plink Today'

    page.current_path.should == '/'

    within '.sign-in-modal' do
      page.find('img[alt="Register with Email"]').click

      fill_in 'First Name', with: 'Frud'
      fill_in 'Email', with: 'furd@example.com'
      fill_in 'Password', with: 'pass1word'
      fill_in 'Verify Password', with: 'pass1word'

      click_on 'Start Earning Rewards'
    end

    within ".welcome-text" do
      page.should have_content 'Welcome, Frud!'
    end

    page.current_path.should == '/wallet'
  end
end
