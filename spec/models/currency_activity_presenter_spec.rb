require 'spec_helper'

describe CurrencyActivityPresenter do

  let(:attributes) {
    {
      is_reward: false,
      award_display_name: 'derp',
      dollar_award_amount: 1.23,
      display_currency_name: 'Plink Pointers',
      currency_award_amount: '123',
      created: Date.parse('2012-07-09'),
      award_type: 'my award'
    }
  }

  let(:subject) {
    CurrencyActivityPresenter.build_currency_activity(
      Plink::DebitsCredit.new(
        double('Plink::DebitCreditRecord', attributes)
      )
    )
  }

  it 'delegates attributes to the given debit/credit' do

    subject.dollar_award_amount.should == 1.23
    subject.currency_award_amount.should == '123'
    subject.display_currency_name.should == 'Plink Pointers'
    subject.award_display_name.should == 'derp'
  end

  describe 'display_date' do
    it 'returns the date of the activity in the format of m/d' do
      subject.display_date.should == '7/9'
    end
  end

  context 'redemption' do
    subject {
      CurrencyActivityPresenter.build_currency_activity(
        Plink::DebitsCredit.new(
          double('Plink::DebitCreditRecord',
               attributes.merge(is_reward: true, award_type: Plink::DebitsCreditRecord.redemption_type)
          )
        )
      )
    }

    it 'returns the right icon_path' do
      subject.icon_path.should == 'history/icon_redeem.png'
    end

    it 'returns the right amount_css_class' do
      subject.amount_css_class.should == 'chart'
    end

    it 'returns the right icon_description' do
      subject.icon_description.should == 'Redemption'
    end
  end

  context 'free award' do
    subject {
      CurrencyActivityPresenter.build_currency_activity(
        Plink::DebitsCredit.new(
          double('Plink::DebitCreditRecord',
               attributes.merge(is_reward: false, award_type: 'Something else')
          )
        )
      )
    }

    it 'returns the right icon_path' do
      subject.icon_path.should == 'history/icon_bonus.png'
    end

    it 'returns the right amount_css_class' do
      subject.amount_css_class.should == 'cyan'
    end

    it 'returns the right icon_description' do
      subject.icon_description.should == 'Bonus'
    end
  end

  context 'non-qualifying award' do

    subject {
      CurrencyActivityPresenter.build_currency_activity(
        Plink::DebitsCredit.new(
          double('Plink::DebitCreditRecord',
               attributes.merge(is_reward: false, award_type: Plink::DebitsCreditRecord.non_qualified_type)
          )
        )
      )
    }

    it 'returns the right icon_path' do
      subject.icon_path.should == 'history/icon_bonus.png'
    end

    it 'returns the right amount_css_class' do
      subject.amount_css_class.should == 'cyan'
    end

    it 'returns the right icon_description' do
      subject.icon_description.should == 'Bonus'
    end
  end

  context 'qualified award' do
    subject {
      CurrencyActivityPresenter.build_currency_activity(
        Plink::DebitsCredit.new(
          double('Plink::DebitCreditRecord',
               attributes.merge(is_reward: false, award_type: Plink::DebitsCreditRecord.qualified_type)
          )
        )
      )
    }

    it 'returns the right icon_path' do
      subject.icon_path.should == 'history/icon_purchase.png'
    end

    it 'returns the right amount_css_class' do
      subject.amount_css_class.should == 'cyan'
    end


    it 'returns the right icon_description' do
      subject.icon_description.should == 'Purchase'
    end
  end
end
