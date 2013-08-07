module UserActions
  def sign_up_user(args)
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)

    visit '/'
    click_on 'Join'

    within '.sign-in-modal' do
      page.find('img[alt="Register with Email"]').click
      fill_in 'First Name', with: args[:first_name]
      fill_in 'Email', with: args[:email]
      fill_in 'Password', with: args[:password]
      fill_in 'Verify Password', with: args[:password]
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
end