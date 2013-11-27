module Intuit
  class AccountPresenter
    attr_accessor :aggr_attempt_date, :aggr_status_code, :aggr_success_date, :currency_code,
      :display_position, :id, :in_intuit, :login_id, :name, :status, :type, :type_description

    def initialize(intuit_account, account_type)
      @aggr_attempt_date = intuit_account[:aggr_attempt_date]
      @aggr_status_code = intuit_account[:aggr_status_code]
      @aggr_success_date = intuit_account[:aggr_success_date]
      @currency_code = intuit_account[:currency_code]
      @display_position = intuit_account[:display_position].to_i
      @id = intuit_account[:account_id]
      @login_id = intuit_account[:institution_login_id]
      @name = intuit_account[:account_nickname]
      @number = intuit_account[:account_number]
      @status = intuit_account[:status]
      @type = standardize_type(account_type)
      @type_description = standardize_description(intuit_account, account_type)
    end

    def to_hash
      {
        aggr_attempt_date: aggr_attempt_date,
        aggr_status_code: aggr_status_code,
        aggr_success_date: aggr_success_date,
        currency_code: currency_code,
        display_position: display_position,
        id: id,
        login_id: login_id,
        name: name,
        number: masked_number,
        number_hash: number_hash,
        number_last_four: number_last_four,
        status: status,
        type: type,
        type_description: type_description
      }
    end

  private

    def masked_number
      @number.sub(/^.*(.{4})/, '****-****-****-\1')
    end

    def number_last_four
      @number[-4..-1]
    end

    def number_hash
      Digest::SHA512.hexdigest(@number)
    end

    def standardize_description(intuit_account, account_type)
      key = account_type == :loan_account ? :loan : account_type
      intuit_account["#{key}_type".to_sym]
    end

    def standardize_type(account_type)
      case account_type
      when :banking_account
        'bankingAccount'
      when :credit_account
        'creditAccount'
      when :investment_account
        'investmentAccount'
      when :loan_account
        'loanAccount'
      else
        nil
      end
    end
  end
end
