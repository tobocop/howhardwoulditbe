module Plink
  class CurrencyActivityService

    NUMBER_OF_ITEMS = 20

    def get_for_user_id(user_id)
      create_debits_credits(DebitsCreditRecord.where('userID = ?', user_id).order("created DESC").limit(NUMBER_OF_ITEMS))
    end

    private

    def create_debits_credits(debits_credits_records)
      debits_credits_records.map { |record| Plink::DebitsCredit.new(record) }
    end

  end
end