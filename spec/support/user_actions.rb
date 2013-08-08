module UserActions
  def sign_up_user(first_name, email, password)
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)

    visit '/'
    click_on 'Join'

    within '.sign-in-modal' do
      page.find('img[alt="Register with Email"]').click
      fill_in 'First Name', with: first_name
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Verify Password', with: password
      click_on 'Start Earning Rewards'
    end
  end

  def sign_in(email, password)
    visit '/'

    click_on 'Sign In'

    within '.sign-in-modal' do
      page.find('img[alt="Sign in with Email"]').click
      fill_in 'user_session_email', with: email
      fill_in 'user_session_password', with: password
      click_on 'Sign In'
    end
  end

  def redeem_for_5(reward)     #make this non dependant on reward amount
    click_on 'Rewards' if current_path != '/rewards'
    page.find('a', text: '$5').click
    within '.modal' do
      page.should have_content reward.name
      click_on 'CONFIRM'
    end
  end

  def validate_5_reward_on_account(reward, user)         #make this non dependant on reward amount
    click_on 'My Account' if current_path != '/account'
    page.should have_text("You have #{user.currency_balance.floor} Plink Points.", count: 2)
    page.should have_content Date.today.to_s(:month_day)
    page.should have_text("$5 #{reward.name}")
    page.should have_text('-500 Plink Points')
    page.should have_image('icon_redeem')
  end
end