module PlinkAdmin
  class RedemptionsController < PlinkAdmin::ApplicationController
    def create
      @user = Plink::UserService.new.find_by_id(params[:user_id])
      if redemption
        last_redemption = Plink::RedemptionRecord.where(userID: @user.id).last
        flash[:notice] = 'Redemption pending' if last_redemption.is_pending
        flash[:notice] = 'Redemption sent' if last_redemption.sent_on.present?
      else
        flash[:notice] = 'Redemption not sent. User does not have enough points or Tango is down.'
      end

      redirect_to edit_user_path(params[:user_id])
    end

  private

    def plink_reward_service
      Plink::RewardService.new
    end

    def plink_redemption_service
      Plink::RewardRedemptionService.new(
        user_id: @user.id,
        reward_amount_id: params[:reward_amount_id],
        user_balance: @user.current_balance,
        first_name: @user.first_name,
        email: @user.email
      )
    end

    def redemption
      begin
        plink_redemption_service.redeem
      rescue Exception => e
        ::Exceptional::Catcher.handle(e) if Rails.env.production?

        flash[:error] = 'Unable to reach Tango. Please try again later.'
        false
      end
    end
  end
end
