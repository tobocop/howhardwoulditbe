module Plink
  class IntuitAccount

    attr_reader :account_name, :bank_name, :requires_reverification, :users_institution_id

    def initialize(attributes)
      @account_name = "#{attributes.fetch(:account_name)} #{attributes.fetch(:account_number_last_four)}"
      @bank_name = attributes.fetch(:bank_name)
      @requires_reverification = attributes.fetch(:requires_reverification)
      @users_institution_id = attributes.fetch(:users_institution_id)
    end

    def active?
      !requires_reverification
    end

  end
end
