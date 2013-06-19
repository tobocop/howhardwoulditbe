class Gigya
  class Config

    include Singleton

    def self.configure(&block)
      raise "Gigya::Config#configure: cannot be called more than once" if instance.configured?
      raise "Gigya::Config#configure: no block given" unless block_given?

      config_class = Struct.new(:api_key, :secret)
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

    def api_key
      @api_key
    end

    def secret
      @secret
    end

    private

    def api_key=(key)
      @api_key = key
    end

    def secret=(secret)
      @secret = secret
    end
  end
end