require 'spec_helper'

describe TrackAwardLinksController do
  describe 'GET create' do
    let(:award_link_service) {
      double(
        Plink::AwardLinkService,
        live?: true,
        redirect_url: '/offers',
        award: false,
        track_click: false
      )
    }

    before do
      Plink::AwardLinkService.stub(:new).and_return(award_link_service)
    end

    it 'gets a new award link service by url' do
      Plink::AwardLinkService.should_receive(:new).with('asd', '3').and_return(award_link_service)

      get :create, { user_id: 3, award_link_url_value: 'asd' }
    end

    context 'when the award_link is live' do
      it 'awards the user' do
        award_link_service.should_receive(:award)

        get :create, { user_id: 3, award_link_url_value: 'asd' }
      end

      it 'redirects the user to the award links redirect url' do
        get :create, { user_id: 3, award_link_url_value: 'asd' }

        response.should redirect_to '/offers'
      end
    end

    context 'when the award_link_service is not live' do
      before do
        award_link_service.stub(:live?).and_return(false)
        get :create, { user_id: 3, award_link_url_value: 'asd' }
      end

      it 'redirects to the home page' do
        response.should redirect_to '/'
      end

      it 'notifies the user the link has live with a flash message' do
        flash[:notice].should == 'Link expired.'
      end
    end
  end
end
