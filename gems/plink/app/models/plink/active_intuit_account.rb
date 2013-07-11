module Plink
  class ActiveIntuitAccount

    attr_reader :bank_name, :account_name

    def initialize(attributes)
      @bank_name = attributes.fetch(:bank_name)
      @account_name = "#{attributes.fetch(:account_name)} #{attributes.fetch(:account_number_last_four)}"
    end

  end
end