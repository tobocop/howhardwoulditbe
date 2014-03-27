module PlinkAdmin
  class UsersController < PlinkAdmin::ApplicationController

    def index
      @users = []
    end

    def edit
      @user = plink_user_record.find(params[:id])
      user_data
    end

    def search
      @search_term = params[:email].present? ? params[:email] : params[:user_id]

      @users = params[:email].present? ?
        plink_user_service.search_by_email(@search_term) :
        Array(plink_user_service.find_by_id(@search_term))

      render :index
    end

    def update
      @user = plink_user_record.find(params[:id])
      user_state = PlinkAdmin::UserUpdateWithActiveStateManager.new(@user)

      if user_state.update_attributes(params[:user])
        flash[:notice] = 'User successfully updated'
      else
        flash[:notice] = 'User could not be updated'
      end

      user_data
      render :edit
    end

    def impersonate
      PlinkAdmin.sign_in_user.call(params[:id], session)
      redirect_to PlinkAdmin.impersonation_redirect_url
    end

    def stop_impersonating
      PlinkAdmin.sign_out_user.call(session)
      redirect_to plink_admin.root_path
    end

    private

    def plink_user_service
      @plink_user_service ||= Plink::UserService.new(true)
    end

    def plink_user_record
      @plink_user_record ||= Plink::UserRecord.unscoped
    end

    def user_data
      @unlock_reasons = Plink::WalletRecord::UNLOCK_REASONS
      @wallet_id = @user.wallet.id
      @users_institutions = Plink::UsersInstitutionRecord.find_by_user_id(@user.id).order('usersInstitutionID desc')
      @fishy_user_ids = Plink::FishyService.fishy_with(@user.id)
      @fishy_status = fishy_status(@fishy_user_ids)
      @rewards = Plink::RewardRecord.live.order('name')
      @duplicate_registrations = Plink::DuplicateRegistrationAttemptRecord.duplicates_by_user_id(@user.id)
    end

    def fishy_status(fishy_user_ids)
      case fishy_user_ids.length
        when 0 then 'Not Fishy'
        when 1 then 'Fishy with themselves'
        else 'Fishy'
      end
    end
  end
end
