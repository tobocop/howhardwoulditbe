require 'singleton'

module Plink
  class Config

    include Singleton

    CONFIGURABLE_OPTIONS = [
        :image_base_url
    ]

    attr_reader *CONFIGURABLE_OPTIONS

    def self.configure
      raise "Plink::Config#configure: cannot be called more than once" if instance.configured?
      raise "Plink::Config#configure: no block given" unless block_given?

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

    def image_base_url=(url)
      @image_base_url = url
    end

  end
end