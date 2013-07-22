module UserActions
  def sign_up_user(args)
    visit '/'

    click_on 'Join'
    click_on 'Join with Email'

    fill_in 'First Name', with: args[:first_name]
    fill_in 'Email', with: args[:email]
    fill_in 'Password', with: args[:password]
    fill_in 'Verify Password', with: args[:password]

    click_on 'Start Earning Rewards'
  end

  def sign_in(email, password)
    visit '/'

    click_on 'Sign In'

    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Log in'
  end
end