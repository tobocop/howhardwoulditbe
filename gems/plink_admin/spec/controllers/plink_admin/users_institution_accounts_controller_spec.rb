require 'spec_helper'

describe PlinkAdmin::UsersInstitutionAccountsController do
  # This is here because Intuit is loaded in the outer app library, so it's impossible to
  # include it in our application without moving that library into its own gem. Since this is admin
  # and the module is tested elsewhere, this should be sufficient until its moved into a gem
  module Intuit; class AccountRemovalService; end; end;

  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'DELETE #destory' do
    let(:delay) { double(remove: true) }
    let(:users_institution_account) {
      double(
        Plink::UsersInstitutionAccountRecord,
        account_id: 213987,
        user_id: 3,
        users_institution_id: 29
      )
    }

    before do
      Plink::UsersInstitutionAccountRecord.stub(:find).and_return(users_institution_account)
      Intuit::AccountRemovalService.stub(:delay).and_return(delay)
    end

    it 'looks up the users institution account by id' do
      Plink::UsersInstitutionAccountRecord.should_receive(:find).with('59').and_return(users_institution_account)

      delete :destroy, id: 59
    end

    it 'calls the account removal with a delayed job' do
      Intuit::AccountRemovalService.should_receive(:delay).with(queue: 'intuit_account_removals').and_return(delay)

      delete :destroy, id: 59
    end

    it 'calls the intuit account removal service to remove it' do
      delay.should_receive(:remove).with(213987, 3, 29)

      delete :destroy, id: 59
    end

    it 'sets a flash notice notifying the admin the request was successful' do
      delete :destroy, id: 59

      flash[:notice].should == 'Account staged for removal'
    end

    it 'redirects the admin back to the user management page' do
      delete :destroy, id: 59

      response.should redirect_to '/users/3/edit'
    end

  end
end
