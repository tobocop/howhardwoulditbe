require 'spec_helper'

describe WalletItemPresenter do

  let(:virtual_currency_presenter) { VirtualCurrencyPresenter.new(virtual_currency: new_virtual_currency(name: 'Plink points')) }
  let(:fake_view_context) { stub(:fake_view_context) }

  context 'populated wallet item' do
    let(:populated_wallet_item) { Plink::WalletItem.new(new_populated_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(populated_wallet_item, virtual_currency: virtual_currency_presenter, view_context: fake_view_context) }

    it 'uses the populated partial' do
      presenter.partial.should == 'populated_wallet_item'
    end

    it 'has the correct special offer type' do
      offer_stub = stub(is_new: false, is_promotion: false)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.special_offer_type.should be_nil
    end

    it 'has the correct special offer type text' do
      offer_stub = stub(is_new: false, is_promotion: false)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.special_offer_type_text.should be_nil
    end

    context 'with a new offer' do
      let(:offer_stub) { stub(is_new: true) }

      before do
        Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      end

      it 'has the correct special offer type' do
        presenter.special_offer_type.should == 'ribbon-new-offer'
      end

      it 'has the correct special offer type text' do
        presenter.special_offer_type_text.should == 'New Partner!'
      end
    end

    context 'with a bonus offer' do
      let(:offer_stub) { stub(is_new: false, is_promotion: true) }

      before do
        Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      end

      it 'has the correct special offer type' do
        presenter.special_offer_type.should == 'ribbon-promo-offer'
      end

      it 'has the correct special offer type text' do
        presenter.special_offer_type_text.should == 'Get double points when you make a qualifying purchase at this partner.'
      end
    end

    it 'has the correct icon_url' do
      offer_stub = stub(image_url: "my_custom_image.png")
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.icon_url.should == Plink::RemoteImagePath.url_for('my_custom_image.png')
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

    it 'has the correct modal_dom_id' do
      offer_stub = stub(id: 15)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.modal_dom_id.should == "offer-details-15"
    end

    it 'returns the correct currency_name' do
      presenter.currency_name.should == 'Plink points'
    end

    it 'returns the offer id of the presented item' do
      offer_stub = stub(id: 152)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      presenter.offer_id.should == 152
    end

    it 'has a JSON representation' do
      offer_stub = stub(max_dollar_award_amount: 15.2, name: 'Taco Bell', image_url: 'my_custom_image.png', id: 2, is_new: true)
      Plink::WalletItem.any_instance.stub(:offer) { offer_stub }
      fake_view_context.should_receive(:wallet_offer_url) { 'test.host/offers/2' }

      JSON.parse(presenter.to_json).symbolize_keys.should == {
        template_name: 'populated_wallet_item',
        special_offer_type: 'ribbon-new-offer',
        modal_dom_id: 'offer-details-2',
        special_offer_type_text: 'New Partner!',
        icon_url: '/my_custom_image.png',
        icon_description: 'Taco Bell',
        currency_name: 'Plink points',
        max_currency_award_amount: '1520',
        wallet_offer_url: 'test.host/offers/2'
      }
    end
  end

  context 'empty wallet item' do
    let(:open_wallet_item) { Plink::WalletItem.new(new_open_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(open_wallet_item, virtual_currency: virtual_currency_presenter, view_context: fake_view_context) }

    it 'uses the open partial for empty wallet items' do
      presenter.partial.should == 'open_wallet_item'
    end


    it 'has the correct icon_url' do
      fake_view_context.should_receive(:image_path).with('icon_emptyslot.png') { 'http://test.host/icon_emptyslot.png' }
      presenter.icon_url.should == 'http://test.host/icon_emptyslot.png'
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

    it 'has a JSON representation' do
      fake_view_context.should_receive(:image_path).with('icon_emptyslot.png') { 'http://test.host/icon_emptyslot.png' }

      JSON.parse(presenter.to_json).symbolize_keys.should == {
        template_name: 'open_wallet_item',
        icon_url: 'http://test.host/icon_emptyslot.png',
        icon_description: 'Empty Slot',
        title: 'This slot is empty.',
        description: 'Select an offer to start earning Plink points.'
      }
    end
  end

  context 'locked wallet item' do
    let(:locked_wallet_item) { Plink::WalletItem.new(new_locked_wallet_item) }
    let(:presenter) { WalletItemPresenter.get(locked_wallet_item, view_context: fake_view_context) }

    it 'uses the locked partial for locked wallet items' do
      presenter.partial.should == 'locked_wallet_item'
    end

    it 'has an icon_url' do
      fake_view_context.should_receive(:image_path).with('icon_lockedslot.png') { 'http://test.host/icon_lockedslot.png' }
      presenter.icon_url.should == 'http://test.host/icon_lockedslot.png'
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

    it 'has a JSON representation' do
      fake_view_context.should_receive(:image_path).with('icon_lockedslot.png') { 'http://test.host/icon_lockedslot.png' }

      JSON.parse(presenter.to_json).symbolize_keys.should == {
        template_name: 'locked_wallet_item',
        icon_url: 'http://test.host/icon_lockedslot.png',
        icon_description: 'Locked Slot',
        title: 'This slot is locked.',
        description: 'Complete an offer to unlock this slot.'
      }
    end
  end
end