require 'spec_helper'

describe ContestReferralsController do
  it_should_behave_like(:tracking_extensions)

  describe '.new' do
    before do
      get :new, {user_id: 123, affiliate_id: 43, contest_id: 23, source: 'my_sweet_source'}
    end

    context 'with a source of facebook_winning_entry_post' do
      before do
        get :new, {user_id: 123, affiliate_id: 43, contest_id: 23, source: 'facebook_winning_entry_post'}
      end

      it 'redirects to the individual contest page' do
        response.should redirect_to contest_path(23)
      end
    end

    context 'without a source of facebook_winning_entry_post' do
      it 'redirects to the contest index page' do
        response.should redirect_to contests_path
      end
    end

    it 'sets the tracking_params referrer_id in the session to the user_id' do
      session[:tracking_params][:referrer_id].should == '123'
    end

    it 'sets the tracking_params affiliate_id in the session to the affiliate_id' do
      session[:tracking_params][:affiliate_id].should == '43'
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
