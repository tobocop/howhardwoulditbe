require 'singleton'

module Tango
  class Config

    include Singleton

    CONFIGURABLE_OPTIONS = [
        :base_url,
        :username,
        :password
    ]

    attr_reader *CONFIGURABLE_OPTIONS

    def self.configure
      raise if instance.configured?

      struct_class = Struct.new(*CONFIGURABLE_OPTIONS)
      config_proxy = struct_class.new

      yield config_proxy

      config_proxy.each_pair do |attribute, value|
        instance.instance_variable_set("@#{attribute}".to_sym, value)
      end

      instance.instance_variable_set(:@configured, true)
    end

    def configured?
      @configured
    end

  end
end