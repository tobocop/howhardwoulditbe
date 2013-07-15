require 'spec_helper'

describe OfferItemPresenter do

  let(:offer) { stub(:offer, id: 32, name: 'BK Whopper') }
  let(:virtual_currency) { stub(:virtual_currency, currency_name: 'Plink points') }
  let(:view_context) { stub(:fake_view_context) }
  let(:presenter) { OfferItemPresenter.new(offer, virtual_currency: virtual_currency, view_context: view_context, linked: true, signed_in: false) }

  describe 'name' do
    it 'returns the name of the offer record' do
      presenter.name.should == 'BK Whopper'
    end
  end

  describe 'id' do
    it 'returns the id from the offer record' do
      presenter.id.should == 32
    end
  end

  describe 'dom_id' do
    it 'returns the generated dom id using the offer record' do
      presenter.dom_id.should == 'offer_32'
    end
  end

  describe 'modal_dom_id' do
    it 'returns the generated dom id for the modal' do
      presenter.modal_dom_id.should == "offer-details-32"
    end
  end

  describe 'image_url' do
    it 'generates the image url' do
      #todo use this: Plink::RemoteImagePath.url_for(offer.image_url)


      Plink::Config.instance.stub(:image_base_url).and_return('/images/')
      offer.stub(:image_url).and_return('burger_king.png')
      presenter.image_url.should == '/images/burger_king.png'
    end

  end

  describe 'image_description' do
    it 'is the offer name' do
      presenter.image_description.should == 'BK Whopper'
    end
  end

  describe 'max_award_amount' do
    it 'returns the max award amount' do
      offer.should_receive(:max_dollar_award_amount).and_return(20)
      virtual_currency.should_receive(:amount_in_currency).with(20).and_return(5)

      presenter.max_award_amount.should == 5
    end
  end

  describe "currency_name" do
    it 'returns the name of the virtual currency' do
      presenter.currency_name.should == 'Plink points'
    end
  end

  describe "tier_descriptions" do
    it 'returns a collection of tier descriptions' do
      virtual_currency.stub(:amount_in_currency).with(0.7).and_return(70)
      virtual_currency.stub(:amount_in_currency).with(1).and_return(100)
      fake_first_tier = stub(:fake_first_tier,
                             minimum_purchase_amount: 5,
                             dollar_award_amount: 0.7
      )
      fake_second_tier = stub(:fake_second_tier,
                              minimum_purchase_amount: 10,
                              dollar_award_amount: 1
      )
      offer.stub(:tiers_by_minimum_purchase_amount).and_return([fake_first_tier, fake_second_tier])
      view_context.stub(:number_to_currency).with(5).and_return('$5')
      view_context.stub(:number_to_currency).with(10).and_return('$10')

      presenter.tier_descriptions.should == [
        "Spend $5 or more, get 70 Plink points.",
        "Spend $10 or more, get 100 Plink points."
      ]
    end
  end

  describe 'call_to_action_link' do
    it 'returns the add to my wallet text if the user has a linked card' do
      presenter.stub(:linked).and_return(true)
      view_context.should_receive(:wallet_offers_path).with({offer_id: 32}).and_return('wallet/offer/path/32')
      view_context.should_receive(:link_to).with('Add To My Wallet',
                                                 'wallet/offer/path/32',
                                                 class: 'button primary-action narrow',
                                                 data: {add_to_wallet: true, offer_dom_selector: "#offer_32"})

      presenter.call_to_action_link
    end

    it 'returns the Link Your Card text if user is signed in' do
      presenter.stub(:linked).and_return(false)
      presenter.stub(:signed_in).and_return(true)
      view_context.should_receive(:account_path).with({link_card: true}).and_return('account/path')
      view_context.should_receive(:link_to).with('Link Your Card',
                                                 'account/path',
                                                 class: 'button primary-action narrow'
      )

      presenter.call_to_action_link
    end

    it 'returns the Join Plink Today text if the user does not have a linked card' do
      presenter.stub(:linked).and_return(false)
      presenter.stub(:signed_in).and_return(false)
      view_context.should_receive(:root_path).with({sign_up: true}).and_return('root/path')
      view_context.should_receive(:link_to).with('Join Plink Today',
                                                 'root/path',
                                                 class: 'button primary-action narrow'
      )

      presenter.call_to_action_link
    end
  end

  describe 'description' do
    it 'displays the offer text' do
      offer.stub(detail_text: 'Earn $virtualCurrencyName$')
      offer.stub(minimum_purchase_amount_tier: '$5')
      Plink::StringSubstituter.should_receive(:gsub).with(offer.detail_text, offer.minimum_purchase_amount_tier, virtual_currency).and_return('Earn Plink points at this location')

      presenter.description.should == 'Earn Plink points at this location'
    end
  end

  describe "as_json" do
    it 'has a JSON representation' do
      presenter.stub(:linked).and_return(true)
      presenter.stub(:signed_in).and_return(true)

      Plink::Config.instance.stub(:image_base_url).and_return('/images/')
      offer.stub(:image_url).and_return('burger_king.png')
      offer.stub(:max_dollar_award_amount).and_return(20)
      virtual_currency.stub(:amount_in_currency).with(20).and_return(5)
      offer.stub(detail_text: 'Earn $virtualCurrencyName$')
      offer.stub(minimum_purchase_amount_tier: '$5')
      Plink::StringSubstituter.stub(:gsub).and_return('Earn Plink points at this location')
      view_context.stub(:wallet_offers_path).with({offer_id: 32}).and_return('wallet/offer/path/32')
      view_context.stub(:link_to).with('Add To My Wallet',
                                       'wallet/offer/path/32',
                                       class: 'button primary-action narrow',
                                       data: {add_to_wallet: true, offer_dom_selector: "#offer_32"})
      .and_return('<a href="#bla">bla</a>')

      JSON.parse(presenter.to_json(linked: true, signed_in: true)).symbolize_keys.should == {
        id: 32,
        name: 'BK Whopper',
        dom_id: 'offer_32',
        modal_dom_id: 'offer-details-32',
        image_url: '/images/burger_king.png',
        image_description: 'BK Whopper',
        max_award_amount: 5,
        currency_name: 'Plink points',
        description: 'Earn Plink points at this location',
        tier_descriptions: [],
        call_to_action_link: '<a href="#bla">bla</a>'
      }
    end
  end
end