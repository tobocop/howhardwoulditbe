module PlinkAdmin
  module ObjectCreationMethods

    def create_admin(options = {})
      new_admin(options).tap(&:save!)
    end

    def new_admin(options = {})
      defaults = {
        email: 'my_admin@example.com',
        password: 'password'
      }
      PlinkAdmin::Admin.new { |admin| apply(admin, defaults, options) }
    end

    def sign_in_admin
      create_admin
      visit '/plink_admin'
      fill_in 'Email', with: 'my_admin@example.com'
      fill_in 'Password', with: 'password'
      click_on 'Sign in'
    end

    def apply(object, defaults, overrides)
      options = defaults.merge(overrides)
      options.each do |method, value_or_proc|
        object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
      end
    end
  end
end
