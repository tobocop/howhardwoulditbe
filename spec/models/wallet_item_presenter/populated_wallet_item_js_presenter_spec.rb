require 'spec_helper'

describe WalletItemPresenter::PopulatedWalletItemJsPresenter do

  let(:presenter) { WalletItemPresenter::PopulatedWalletItemJsPresenter.new }

  describe 'template_name' do
    it 'returns a template placeholder for the icon url' do
      presenter.template_name.should == '{{template_name}}'
    end
  end

  describe 'special_offer_type' do
    it 'returns a special_offer_type placeholder' do
      presenter.special_offer_type.should == '{{special_offer_type}}'
    end
  end

  describe 'special_offer_type_text' do
    it 'returns a special_offer_type_text placeholder' do
      presenter.special_offer_type_text.should == '{{special_offer_type_text}}'
    end
  end

  describe 'icon_url' do
    it 'returns a template placeholder for the icon url' do
      presenter.icon_url.should == '{{icon_url}}'
    end
  end

  describe 'modal_dom_id' do
    it 'returns a template placeholder for the dom id' do
      presenter.modal_dom_id.should == '{{modal_dom_id}}'
    end
  end

  describe 'icon_description' do
    it 'returns the template placeholder for the icon description' do
      presenter.icon_description.should == '{{icon_description}}'
    end
  end

  describe 'max_currency_award_amount' do
    it 'returns the template placeholder for the max_currency_award_amount' do
      presenter.max_currency_award_amount.should == '{{max_currency_award_amount}}'
    end
  end

  describe 'currency_name' do
    it 'returns the template placeholder for the currency_name' do
      presenter.currency_name.should == '{{currency_name}}'
    end
  end


  describe 'offer_id' do
    it 'returns the template placeholder for the offer_id' do
      presenter.offer_id.should == '{{offer_id}}'
    end
  end


  describe 'wallet_offer_url' do
    it 'returns the template placeholder for the wallet_offer_url' do
      presenter.wallet_offer_url.should == '{{wallet_offer_url}}'
    end
  end
end