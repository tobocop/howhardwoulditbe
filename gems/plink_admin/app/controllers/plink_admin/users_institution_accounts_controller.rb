module PlinkAdmin
  class UsersInstitutionAccountsController < ApplicationController
    def destroy
      users_institution_account_record = Plink::UsersInstitutionAccountRecord.find(params[:id])
      Intuit::AccountRemovalService.remove(
        users_institution_account_record.account_id,
        users_institution_account_record.user_id,
        users_institution_account_record.users_institution_id
      )

      flash[:notice] = 'Account successfully removed'
      redirect_to plink_admin.edit_user_path(users_institution_account_record.user_id)
    end
  end
end
