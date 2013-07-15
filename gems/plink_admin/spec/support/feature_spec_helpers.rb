module PlinkAdmin
  module FeatureSpecHelpers
    def sign_in_admin(args)
      visit '/'

      fill_in 'Email', with: args[:email]
      fill_in 'Password', with: args[:password]

      click_on 'Sign in'
    end
  end
end