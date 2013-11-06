module PlinkAdmin
  class TangoController < ApplicationController
    def kill_switch
      @tango_offline = Plink::RewardRecord.where(isTangoRedemption: true, isActive: true).
        any? {|record| !record[:is_redeemable]}
    end

    def toggle_redeemable
      method = params[:tango_redemptions] == 'activate' ? :resume_redemptions : :halt_redemptions

      Plink::TangoRedemptionShutoffService.send(method)
      flash[:notice] = "Successfully #{params[:tango_redemptions]}d Tango Redemptions"

      redirect_to :tango_kill_switch
    end
  end
end
