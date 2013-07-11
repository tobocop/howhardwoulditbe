module Plink
  class CurrencyActivityService

    def get_for_user_id(user_id)
      create_debits_credits(DebitsCreditRecord.where('userID = ?', user_id).order("created DESC").limit(number_of_records_to_return))
    end

    private

    def create_debits_credits(debits_credits_records)
      debits_credits_records.map { |record| Plink::DebitsCredit.new(record) }
    end

    def number_of_records_to_return
      20
    end

  end
end