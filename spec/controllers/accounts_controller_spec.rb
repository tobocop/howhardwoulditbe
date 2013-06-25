require 'spec_helper'

describe AccountsController do
  let(:user) { new_user }

  before(:each) do
    controller.stub(current_user: user)
  end

  describe 'GET show' do
    it 'assigns current_tab' do
      get :show
      assigns(:current_tab).should == 'account'
    end

    it 'assigns @user_has_account' do
      ActiveIntuitAccount.count.should == 0

      get :show

      assigns(:user_has_account).should == false
    end
  end
end
