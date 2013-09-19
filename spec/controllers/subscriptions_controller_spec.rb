require 'spec_helper'

describe SubscriptionsController do
  let(:mock_plink_user_service) { mock(:plink_user_service) }

  before do
    set_virtual_currency
    controller.stub(plink_user_service: mock_plink_user_service)
  end

  describe 'GET edit' do
    it 'sets @email_address' do
      get :edit, email_address: 'mail@example.com'

      assigns(:email_address).should == 'mail@example.com'
    end
  end

  describe 'PUT update' do
    context 'json response' do
      before do
        set_current_user(id: 3)
      end

      it 'updates the users email preferences with the given value' do
        mock_plink_user_service.should_receive(:update_subscription_preferences).with(3, is_subscribed: '0')

        xhr :put, :update, is_subscribed: '0', format: 'json'

        JSON.parse(response.body).should == {}
      end
    end

    context 'html response' do

      context 'with a current user' do
        before do
          mock_plink_user_service.stub(:find_by_email).with('foo@example.com').and_return(mock(:user, id: 3))
          mock_plink_user_service.stub(:update_subscription_preferences).with(3, is_subscribed: '0')
        end

        it 'redirects to the home page with a flash message' do
          put :update, email_address: 'foo@example.com', is_subscribed: '0'

          response.should redirect_to root_url
          flash[:notice].should == 'Your subscription preferences have been successfully updated.'
        end

        it 'updates the users subscription' do
          mock_plink_user_service.should_receive(:find_by_email).with('foo@example.com').and_return(mock(:user, id: 3))
          mock_plink_user_service.should_receive(:update_subscription_preferences).with(3, is_subscribed: '0')

          put :update, email_address: 'foo@example.com', is_subscribed: '0'
        end
      end

      context 'without a current user' do
        it 'redirects to the home page if the user cannot be found' do
          mock_plink_user_service.stub(:find_by_email).with('foo@example.com').and_return(nil)

          put :update, email_address: 'foo@example.com', is_subscribed: '0'

          response.should redirect_to root_url
          flash[:notice].should == 'Email address does not exist in our system.'
        end

        it 'redirects to the home page if an email is not provided and the user is not logged in' do

          put :update, is_subscribed: '0'

          response.should redirect_to root_url
          flash[:notice].should == 'Email address does not exist in our system.'
        end
      end
    end
  end

  describe 'GET unsubscribe' do
    it 'immediately unsubscribes the user for the given email address' do
      mock_plink_user_service.should_receive(:find_by_email).with('mail@example.com').and_return(mock(:user, id: 3))
      mock_plink_user_service.should_receive(:update_subscription_preferences).with(3, is_subscribed: 0)

      get :unsubscribe, email_address: 'mail@example.com'

      response.should redirect_to root_url
      flash[:notice].should == 'You have been un-subscribed.'
    end

    it 'returns notification if the user cannot be found' do
      mock_plink_user_service.should_receive(:find_by_email).with('notthere@example.com').and_return(nil)

      get :unsubscribe, email_address: 'notthere@example.com'

      response.should redirect_to root_url
      flash[:notice].should == 'Email address does not exist in our system.'
    end
  end

  describe 'GET contest_unsubscribe' do
    it 'immediately unsubscribes the user from contest reminders' do
      mock_plink_user_service.should_receive(:find_by_email).with('mail@example.com').and_return(mock(:user, id: 3))
      mock_plink_user_service.should_receive(:update_subscription_preferences).with(3, daily_contest_reminder: 0)

      get :contest_unsubscribe, email_address: 'mail@example.com'

      response.should redirect_to contests_url
      flash[:notice].should == "You've been successfully unsubscribed from future contest notifications."
    end

    it 'returns notification if the user cannot be found' do
      mock_plink_user_service.should_receive(:find_by_email).with('notthere@example.com').and_return(nil)

      get :contest_unsubscribe, email_address: 'notthere@example.com'

      response.should redirect_to contests_url
      flash[:notice].should == 'Email address does not exist in our system.'
    end
  end
end
