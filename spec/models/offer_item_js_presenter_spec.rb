require 'spec_helper'

describe OfferItemJsPresenter do

  let(:virtual_currency) { stub(:virtual_currency, currency_name: 'Plink points') }
  let(:presenter) { OfferItemJsPresenter.new(virtual_currency: virtual_currency) }

  describe 'javascript?' do
    it 'tells the public it is for javascript templates' do
      presenter.javascript?.should be_true
    end
  end

  describe 'name' do
    it 'returns the name placeholder' do
      presenter.name.should == '{{name}}'
    end
  end

  describe 'id' do
    it 'returns the id placeholder' do
      presenter.id.should == '{{id}}'
    end
  end

  describe 'dom_id' do
    it 'returns the generated dom id placeholder' do
      presenter.dom_id.should == '{{dom_id}}'
    end
  end

  describe 'modal_dom_id' do
    it 'returns the generated dom id placeholder' do
      presenter.modal_dom_id.should == "{{modal_dom_id}}"
    end
  end

  describe 'image_url' do
    it 'returns the image url placeholder' do
      presenter.image_url.should == '{{image_url}}'
    end
  end

  describe 'image_description' do
    it 'is the image description placeholder' do
      presenter.image_description.should == '{{image_description}}'
    end
  end

  describe 'max_award_amount' do
    it 'returns the max award amount placeholder' do
      presenter.max_award_amount.should == '{{max_award_amount}}'
    end
  end

  describe "currency_name" do
    it 'returns the name of the virtual currency placeholder' do
      presenter.currency_name.should == '{{currency_name}}'
    end
  end

  describe 'call_to_action_link' do
    it 'returns call to action placeholder' do
      presenter.call_to_action_link.should == '{{{call_to_action_link}}}'
    end
  end

  describe 'description' do
    it 'returns the description placeholder as html safe' do
      presenter.description.should == '{{{description}}}'
    end
  end
end