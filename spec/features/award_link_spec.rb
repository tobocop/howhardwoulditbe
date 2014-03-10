require 'spec_helper'

describe 'award links' do
  let!(:virtual_currency) { create_virtual_currency }
  let!(:user) { create_user(email: 'test@example.com', password: 'test123') }
  let(:award_type) { create_award_type }
  let!(:award_link) {
    create_award_link(
      award_type_id: award_type.id,
      dollar_award_amount: 1.23,
      url_value: 'SOMEHASHORUUID',
      redirect_url: '/rewards'
    )
  }

  before do
    create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
  end

  it 'awards a user and redirects them', :vcr, js: true do
    visit "/ta/#{user.id}/#{award_link.url_value}"
    page.should have_content('CHOOSE YOUR REWARD')
    visit '/'
    sign_in('test@example.com', 'test123')
    page.should have_content('You have 123 Plink points.')
  end
end
