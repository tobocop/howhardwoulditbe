require 'spec_helper'

describe PlinkAdmin::TangoController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET kill_switch' do
    it 'responds successfully' do
      get :kill_switch

      response.should be_success
    end

    it 'renders the kill_switch view' do
      get :kill_switch

      response.should render_template 'kill_switch'
    end

    it 'returns the current state of tango' do
      Plink::RewardRecord.should_receive(:where).
        with(isTangoRedemption: true, isActive: true).
        and_return([{is_redeemable: true}])

      get :kill_switch

      assigns(:tango_offline).should be_false
    end
  end

  describe 'POST toggle_redeemable' do
    it 'redirects to kill_switch' do
      post :toggle_redeemable

      response.should redirect_to :tango_kill_switch
    end

    it 'calls to resume redemptions when given "activate"' do
      Plink::TangoRedemptionShutoffService.should_receive(:resume_redemptions)

      post :toggle_redeemable, tango_redemptions: 'activate'
    end

    it 'calls to halt redemptions when given "deactivate"' do
      Plink::TangoRedemptionShutoffService.should_receive(:halt_redemptions)

      post :toggle_redeemable, tango_redemptions: 'deactivate'
    end

    it 'returns a flash notice' do
      post :toggle_redeemable, tango_redemptions: 'deactivate'

      flash[:notice].should == 'Successfully deactivated Tango Redemptions'
    end
  end
end
