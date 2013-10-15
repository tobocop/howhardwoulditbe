require 'spec_helper'

describe SharePagesController do
  describe 'GET show' do
    let(:share_page) { create_share_page }

    it 'should be successful' do
      get :show, id: share_page.id

      response.should be_succes
    end

    it 'sets @share_page' do
      get :show, id: share_page.id

      assigns(:share_page).should_not be_nil
      assigns(:share_page).should be_instance_of Plink::SharePageRecord
    end
  end
end
