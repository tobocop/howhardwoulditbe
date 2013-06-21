class Gigya
  class Config

    include Singleton

    CONFIGURABLE_OPTIONS = [
        :api_key,
        :secret,
        :registration_redirect_base_url
    ]

    attr_reader *CONFIGURABLE_OPTIONS

    def self.configure(&block)
      raise "Gigya::Config#configure: cannot be called more than once" if instance.configured?
      raise "Gigya::Config#configure: no block given" unless block_given?

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

    def api_key=(key)
      @api_key = key
    end

    def secret=(secret)
      @secret = secret
    end

    def registration_redirect_base_url=(url)
      @registration_redirect_base_url = url
    end
  end
end