require 'spec_helper'

describe 'guest behavior' do

  before do
    create_virtual_currency(name: 'Plink Points', subdomain: VirtualCurrency::DEFAULT_SUBDOMAIN)
    create_offer(advertiser_name: 'Old Nervy')
  end

  it 'can view all offers' do
    visit '/'

    click_on 'view offers'

    page.should have_content 'Earn Plink Points at these locations.'
    page.should have_content 'Old Nervy'
  end
end
