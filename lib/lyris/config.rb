module Lyris
  class Config

    include Singleton

    CONFIGURABLE_OPTIONS = [
      :site_id,
      :password,
      :mailing_list_id
    ]

    attr_reader *CONFIGURABLE_OPTIONS

    def self.configure(&block)
      raise "Lyris::Config#configure: cannot be called more than once" if instance.configured?
      raise "Lyris::Config#configure: no block given" unless block_given?

      config_class = Struct.new(*CONFIGURABLE_OPTIONS)
      config = config_class.new

      yield config

      config.each_pair do |method, value|
        instance.send("#{method}=", value)
      end

      instance.instance_variable_set(:@configured, true)
    end

    def configured?
      @configured
    end

  private

    def site_id=(site_id)
      @site_id = site_id
    end

    def password=(password)
      @password = password
    end

    def mailing_list_id=(id)
      @mailing_list_id = id
    end
  end
end
