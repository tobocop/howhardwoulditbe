require 'spec_helper'

describe Intuit::AccountsPresenter do
  let(:intuit_response) do
    {:loan_account=>
      [{:account_id=>"400006583993",
        :status=>"ACTIVE",
        :account_number=>"1000000001",
        :account_nickname=>"My Mortgage",
        :display_position=>"5",
        :institution_id=>"100000",
        :description=>"Description",
        :balance_amount=>"1029.05",
        :balance_date=>"2013-10-29T00:00:00-07:00",
        :aggr_success_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_attempt_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_status_code=>"0",
        :currency_code=>"BND",
        :institution_login_id=>"128700189",
        :loan_type=>"MORTGAGE",
        :next_payment=>"1029.05",
        :next_payment_date=>"2020-04-01T00:00:00-07:00",
        :autopay_enrolled=>"true",
        :collateral=>"1029.05",
        :current_school=>"Cur School",
        :first_payment_date=>"2020-04-01T00:00:00-07:00",
        :guarantor=>"Guarantor",
        :first_mortgage=>"false",
        :loan_payment_freq=>"MONTHLY",
        :payment_min_amount=>"1029.05",
        :original_school=>"Orig School",
        :recurring_payment_amount=>"1029.05",
        :lender=>"Lender"
      }],
     :banking_account=>
      [{:account_id=>"400006583994",
        :status=>"ACTIVE",
        :account_number=>"1000002222",
        :account_nickname=>"My Savings",
        :display_position=>"7",
        :institution_id=>"100000",
        :balance_amount=>"1029.05",
        :balance_date=>"2013-10-29T00:00:00-07:00",
        :aggr_success_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_attempt_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_status_code=>"0",
        :currency_code=>"INR",
        :institution_login_id=>"128700189",
        :banking_account_type=>"SAVINGS"
      }],
     :investment_account=>
      [{:account_id=>"400006583997",
        :status=>"ACTIVE",
        :account_number=>"0000000000",
        :account_nickname=>"My Brokerage",
        :display_position=>"9",
        :institution_id=>"100000",
        :balance_amount=>"1029.05",
        :balance_date=>"2013-10-29T00:00:00-07:00",
        :aggr_success_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_attempt_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_status_code=>"0",
        :currency_code=>"INR",
        :institution_login_id=>"128700189",
        :investment_account_type=>"TAXABLE",
        :current_balance=>"1029.05"
      }],
     :credit_account=>
      [{:account_id=>"400006583998",
        :status=>"ACTIVE",
        :account_number=>"8000006666",
        :account_nickname=>"My Line of Credit",
        :display_position=>"4",
        :institution_id=>"100000",
        :balance_date=>"2013-10-29T00:00:00-07:00",
        :aggr_success_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_attempt_date=>"2013-10-29T21:05:53.029-07:00",
        :aggr_status_code=>"0",
        :currency_code=>"INR",
        :institution_login_id=>"128700189",
        :credit_account_type=>"LINEOFCREDIT",
        :current_balance=>"-1029.05"
      }]
    }
  end

  subject(:institution_accounts) { Intuit::AccountsPresenter.new(intuit_response) }

  describe '.accounts' do
    it 'returns all accounts' do
      institution_accounts.accounts.length.should == 4
    end

    it 'returns a collection of institution account presenters' do
      institution_accounts.accounts.map(&:class).uniq.should == [Intuit::AccountPresenter]
    end
  end
end
