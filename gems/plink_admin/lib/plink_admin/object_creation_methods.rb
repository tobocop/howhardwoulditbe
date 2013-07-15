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


    def apply(object, defaults, overrides)
      options = defaults.merge(overrides)
      options.each do |method, value_or_proc|
        object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
      end
    end
  end
end
