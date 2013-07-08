require 'spec_helper'

describe 'guest behavior' do

  describe 'viewing offers and rewards' do

    before do
      currency = create_virtual_currency(name: 'Plink Points', subdomain: Plink::VirtualCurrency::DEFAULT_SUBDOMAIN)

      advertiser = create_advertiser(advertiser_name: 'Old Nervy', logo_url: '/assets/test/oldnavy.png')

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
              new_reward_amount(dollar_award_amount: 15, is_active: false)
          ]
      )

      create_reward(name: 'Should Not Exist Gift Card', is_active: false, amounts:
          [
              new_reward_amount(dollar_award_amount: 5, is_active: true)
          ]
      )
    end

    it 'allows a user to see them' do
      visit '/'

      click_on 'view offers'

      page.should have_content 'Earn Plink Points at these locations.'
      page.should have_css('img[src="/assets/test/oldnavy.png"]')
      page.should have_content '143 Plink Points'

      visit '/rewards'

      page.should have_content 'Redeem Plink Points for these rewards'
      page.should have_content 'Walmart Gift Card'
      page.should have_content '$5'
      page.should have_content '$10'
      page.should_not have_content '$15'

      page.should_not have_content 'Should Not Exist Gift Card'
    end
  end

  it 'can submit a contact us form', js: true do

    visit '/'

    click_on 'Contact Us'

    click_button 'Contact Us'

    page.should have_content 'First name can\'t be blank'
    page.should have_content 'Last name can\'t be blank'
    page.should have_content 'Email can\'t be blank'

    fill_in 'First Name', with: 'Bob'
    fill_in 'Last Name', with: 'Jones'
    fill_in 'Email', with: 'bob@example.com'

    page.should have_checked_field 'Customer Support'
    page.should have_unchecked_field 'Close my account'
    page.should have_unchecked_field 'Advertising and Business Development'
    page.should have_unchecked_field 'Investor Relations'

    choose 'Advertising and Business Development'

    fill_in 'contact_form[message_text]', with: 'Some message'

    click_button 'Contact Us'

    page.should have_content 'Thank you for contacting us.'

    ActionMailer::Base.deliveries.count.should == 1

    contact_email = ActionMailer::Base.deliveries.first
    contact_email.subject.should == 'Contact Form: [Advertising and Business Development]'
  end
end
