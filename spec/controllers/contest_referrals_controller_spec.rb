require 'spec_helper'

describe ContestReferralsController do
  describe '.new' do
    before do
      get :new, {user_id: 123, affiliate_id: 43, contest_id: 23, source: 'my_sweet_source'}
    end
    it 'redirects to the contest index page' do
      response.should redirect_to contests_path
    end

    it 'sets the referrer_id in the session' do
      session[:referrer_id].should == 123
    end

    it 'sets the affiliate_id in the session' do
      session[:affiliate_id].should == 43
    end

    it 'sets the tracking_params affiliate_id in the session to the affiliate_id' do
      session[:tracking_params][:affiliate_id].should == 43
    end
    it 'sets the tracking_params sub_id_three in the session to the contest id' do
      session[:tracking_params][:sub_id_three].should == 'contest_id_23'
    end

    it 'sets the tracking_params sub_id in the session to the source' do
      session[:tracking_params][:sub_id].should == 'my_sweet_source'
    end

    it 'sets the source in session to be used later' do
      session[:contest_source].should == 'my_sweet_source'
    end
  end
end
