require 'spec_helper'

describe WalletItemPresenter::LockedWalletItemJsPresenter do

  let(:presenter) { WalletItemPresenter::LockedWalletItemJsPresenter.new }

  describe 'template_name' do
    it 'returns a template placeholder for the icon url' do
      presenter.template_name.should == '{{template_name}}'
    end
  end

  describe 'icon_url' do
    it 'returns a template placeholder for the icon url' do
      presenter.icon_url.should == '{{icon_url}}'
    end
  end

  describe 'icon_description' do
    it 'returns the template placeholder for the icon description' do
      presenter.icon_description.should == '{{icon_description}}'
    end
  end

  describe 'title' do
    it 'returns the template placeholder for the icon description' do
      presenter.description.should == '{{description}}'
    end
  end

  describe 'description' do
    it 'returns the template placeholder for the icon description' do
      presenter.description.should == '{{description}}'
    end
  end
end