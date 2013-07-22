module Plink
  class IntuitAccount

    attr_reader :bank_name, :account_name, :requires_reverification

    def initialize(attributes)
      @bank_name = attributes.fetch(:bank_name)
      @account_name = "#{attributes.fetch(:account_name)} #{attributes.fetch(:account_number_last_four)}"
      @requires_reverification = attributes.fetch(:requires_reverification)
    end

    def status
      requires_reverification ? 'Inactive' : 'Active'
    end

  end
end