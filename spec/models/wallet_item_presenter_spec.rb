require 'spec_helper'

describe WalletItemPresenter do

  let(:virtual_currency_presenter) { VirtualCurrencyPresenter.new(virtual_currency: new_virtual_currency) }

  context 'populated wallet item' do
    let(:populated_wallet_item) { Plink::WalletItem.new(new_populated_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(populated_wallet_item, virtual_currency: virtual_currency_presenter) }

    it 'uses the populated partial' do
      presenter.partial.should == 'populated_wallet_item'
    end

    it 'has the correct icon_path' do
      offer_stub = stub(image_url: "my_custom_image.png")
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.icon_path.should == Plink::RemoteImagePath.url_for('my_custom_image.png')
    end

    it 'has the correct icon description' do
      offer_stub = stub(name: "Old Navy")
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.icon_description.should == 'Old Navy'
    end

    it 'has the correct max_currency_award_amount' do
      offer_stub = stub(max_dollar_award_amount: 15.2)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.max_currency_award_amount.should == "1520"
    end

    it 'returns the correct currency_name' do
      presenter.currency_name.should == 'Plink points'
    end

    it 'returns the offer id of the presented item' do
      offer_stub = stub(id: 152)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.offer_id.should == 152
    end

  end

  context 'empty wallet item' do
    let(:open_wallet_item) { Plink::WalletItem.new(new_open_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(open_wallet_item, virtual_currency: virtual_currency_presenter) }

    it 'uses the open partial for empty wallet items' do
      presenter.partial.should == 'open_wallet_item'
    end


    it 'has the correct icon_path' do
      presenter.icon_path.should == 'icon_emptyslot.png'
    end

    it 'has the correct icon_description' do
      presenter.icon_description.should == 'Empty Slot'
    end

    it 'has the correct title' do
      presenter.title.should == 'This slot is empty.'
    end

    it 'has a description that can hold the virtual currency name' do
      presenter.description.should == "Select an offer to start earning Plink points."
    end
  end

  context 'locked wallet item' do
    let(:locked_wallet_item) { Plink::WalletItem.new(new_locked_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(locked_wallet_item) }

    it 'uses the locked partial for locked wallet items' do
      presenter.partial.should == 'locked_wallet_item'
    end

    it 'has an icon_path' do
      presenter.icon_path.should == 'icon_lockedslot.png'
    end

    it 'has an icon_description' do
      presenter.icon_description.should == 'Locked Slot'
    end

    it 'has a title' do
      presenter.title.should == 'This slot is locked.'
    end

    it 'has a description' do
      presenter.description.should == 'Complete an offer to unlock this slot.'
    end
  end
end