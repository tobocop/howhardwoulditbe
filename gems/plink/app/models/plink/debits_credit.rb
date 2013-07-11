module Plink
  class DebitsCredit

    attr_reader :debits_credit_record

    def initialize(debits_credit_record)
      @debits_credit_record = debits_credit_record
    end

    delegate :award_display_name, :dollar_award_amount, :display_currency_name, to: :debits_credit_record

    def currency_award_amount
      debits_credit_record.currency_award_amount.to_i.to_s
    end

    def is_reward?
      debits_credit_record.is_reward
    end

    def is_qualified?
      debits_credit_record.award_type == Plink::DebitsCreditRecord.qualified_type ? true : false
    end

    def is_non_qualified?
      debits_credit_record.award_type == Plink::DebitsCreditRecord.non_qualified_type ? true : false
    end

    def is_free?
      unless (is_qualified? || is_non_qualified? || is_reward?)
        true
      else
        false
      end
    end

    def awarded_on
      Date.parse(debits_credit_record.created.to_s)
    end
  end
end
