require 'spec_helper'

describe SharePagesController do
  describe 'GET show' do
    let(:share_page) { create_share_page }

    before do
      user = set_current_user
      set_virtual_currency(currency_name: 'Bit Bucks', amount_in_currency: 24)

      get :show, id: share_page.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'sets @user' do
      assigns(:user).should_not be_nil
    end

    it 'sets @affiliate_id' do
      assigns(:affiliate_id).should be_instance_of Fixnum
    end

    it 'sets @share_page' do
      assigns(:share_page).should_not be_nil
      assigns(:share_page).should be_instance_of Plink::SharePageRecord
    end
  end
end
