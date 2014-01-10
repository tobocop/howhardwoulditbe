require 'spec_helper'

describe ReverificationsController do
  describe 'GET start' do
    let(:institution) { double(id: 9) }
    let(:users_institution_record) { double(intuit_institution_login_id: 2) }
    let(:user_reverification_record) {
      double(
        id:3,
        institution_record: institution,
        update_attributes: true,
        users_institution_record: users_institution_record
      )
    }

    before do
      Plink::UserReverificationRecord.stub(:find).and_return(user_reverification_record)
    end

    it 'tracks the reverification record as started' do
      time_now = Time.zone.now
      Time.stub(zone: double(now: time_now))

      user_reverification_record.should_receive(:update_attributes).with(started_on: time_now)

      get :start, id: 3
    end

    it 'stores the id of the reverification record to the session' do
      get :start, id: 3

      session[:reverification_id].should == 3
    end

    it 'stores the intuit institution login id of the users institution to the session' do
      get :start, id: 3

      session[:intuit_institution_login_id].should == 2
    end

    it 'redirects the user to their institutions authentication form' do
      get :start, id: 3

      response.should redirect_to(institution_authentication_path(9))
    end
  end

  describe 'GET complete' do
    let(:user_reverification_record) { double(update_attributes: true) }

    before do
      session[:reverification_id] = 4
      session[:intuit_institution_login_id] = 9

      Plink::UserReverificationRecord.stub(:find).and_return(user_reverification_record)
    end

    it 'renders the reverification complete partial' do
      get :complete

      response.should render_template partial: 'reverifications/_complete'
    end

    it 'looks up the reverification record from the id in the session' do
      Plink::UserReverificationRecord.should_receive(:find).with(4).and_return(user_reverification_record)

      get :complete
    end

    it 'tracks the reverification record as completed' do
      time_now = Time.zone.now
      Time.stub(zone: double(now: time_now))

      user_reverification_record.should_receive(:update_attributes).with(completed_on: time_now)

      get :complete
    end

    it 'removes the id of the reverification record from the session' do
      get :complete

      session[:reverification_id].should be_nil
    end

    it 'removes the intuit institution login id of the users institution from the session' do
      get :complete

      session[:intuit_institution_login_id].should be_nil
    end
  end
end
