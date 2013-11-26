require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe AccountsController do
  it_should_behave_like(:tracking_extensions)
  it_should_behave_like(:auto_login_extensions)

  let(:intuit_account) {
    Plink::IntuitAccount.new(
        account_name: 'account',
        account_number_last_four: 1234,
        bank_name: 'bank',
        requires_reverification: false,
        reverify_id: 143,
        users_institution_id: 3
    )
  }

  let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new({10 => intuit_account}) }

  let(:debits_credit) {
    Plink::DebitsCredit.new(
        mock('Plink::DebitCreditRecord', {
            is_reward: false,
            award_display_name: 'derp',
            dollar_award_amount: 1.23,
            display_currency_name: 'Plink Pointers',
            currency_award_amount: '123',
            created: Date.parse('2012-07-09'),
            award_type: 'my award'
        })
    )
  }

  let(:fake_currency_activity_service) { mock("CurrencyService", get_for_user_id: [debits_credit, debits_credit]) }

  context 'actions that require authentication' do
    before(:each) do
      set_current_user(id: 10)
      set_virtual_currency
      controller.stub(plink_intuit_account_service: fake_intuit_account_service)
      controller.stub(plink_currency_activity_service: fake_currency_activity_service)
    end

    describe 'GET show' do
      it 'assigns current_tab' do
        get :show
        assigns(:current_tab).should == 'account'
      end

      it 'assigns @user_has_account' do
        get :show

        assigns(:user_has_account).should == true
      end

      it 'assigns a @card_link_url' do
        session[:tracking_params] = {
          referrer_id: 123,
          affiliate_id: 456
        }

        Plink::CardLinkUrlGenerator.any_instance.should_receive(:create_url).with(referrer_id: 123, affiliate_id: 456).and_return { 'http://www.mywebsite.example.com' }

        get :show

        assigns(:card_link_url).should == 'http://www.mywebsite.example.com'
      end

      it 'assigns a @card_change_url' do
        Plink::CardLinkUrlGenerator.any_instance.stub(:change_url) { 'http://www.mywebsite.example.com' }

        get :show

        assigns(:card_change_url).should == 'http://www.mywebsite.example.com'
      end

      it 'assigns a @card_reverify_url' do
        Plink::CardLinkUrlGenerator.any_instance.stub(:card_reverify_url) { 'http://www.mywebsite.example.com' }

        get :show

        assigns(:card_reverify_url).should == 'http://www.mywebsite.example.com'

      end

      it 'assigns an @bank_account' do
        get :show
        assigns(:bank_account).should == intuit_account
      end

      it 'assigns a @currency_activity' do
        fake_currency_activity_service.should_receive(:get_for_user_id).with(10).and_return(['1'])
        CurrencyActivityPresenter.should_receive(:build_currency_activity).with('1').and_return('presented activity')

        get :show
        assigns(:currency_activity).should == ['presented activity']
      end

      it 'redirects if the current user is not logged in' do
        controller.stub(user_logged_in?: false)
        get :show
        response.should be_redirect
      end
    end

    describe 'PUT update' do

      let(:fake_user_service) { mock(:user_service) }
      let(:user) { set_current_user(id: 10, email: 'goo@example.com') }

      context 'when successful' do
        before do
          controller.stub(plink_user_service: fake_user_service)
          fake_user_service.stub(:verify_password).with(10, 'password').and_return(true)
          fake_user_service.stub(:update).with(10, {'email' => 'goo@example.com', 'first_name' => 'Joseph'}).and_return(user)
        end

        it 'updates the user with the given attributes' do
          fake_user_service.should_receive(:update).with(10, {'email' => 'goo@example.com', 'first_name' => 'Joseph'}).and_return(mock(:plink_user, valid?: true))

          put :update, email: 'goo@example.com', password: 'password', first_name: 'Joseph'

          response.should be_success
        end

        it 'returns a JSON response' do
          put :update, email: 'goo@example.com', first_name: 'Joseph', password: 'password'

          body = JSON.parse(response.body)
          body.should == {'email' => 'goo@example.com', 'first_name' => 'Joseph'}
        end

        it 'returns a JSON response with a truncated first name' do
          fake_user_service.stub(:update).with(10, {'email' => 'goo@example.com', 'first_name' => 'Hoobastankmynizzleforizzle'}).and_return(user)
          put :update, email: 'goo@example.com', first_name: 'Hoobastankmynizzleforizzle', password: 'password'

          body = JSON.parse(response.body)
          body.should == {'email' => 'goo@example.com', 'first_name' => 'Hoobastankmyni'}
        end

        context 'when the updating password' do
          it 'updates the password via the user service' do
            fake_user_service.should_receive(:update_password).with(10, new_password: '123456', new_password_confirmation: '123456').and_return(user)
            fake_user_service.should_not_receive(:update)

            put :update, password: 'password', new_password: '123456', new_password_confirmation: '123456'
          end
        end

        context 'when updating the email address' do
          let(:user) { set_current_user(id: 10, email: 'goo@example.com') }

          before do
            fake_user_service.stub(:update).with(10, {'email' => 'goober@example.com'}).and_return(user)
          end

          it 'updates the e-mail in lyris' do
            delay_double = double(:update_users_email)
            Lyris::UserService.should_receive(:delay).and_return(delay_double)
            delay_double.should_receive(:update_users_email).with('goo@example.com', 'goober@example.com')

            put :update, email: 'goober@example.com', password: 'password'
          end
        end
      end

      context 'when the password is wrong' do
        before do
          controller.stub(plink_user_service: fake_user_service)

          fake_user_service.stub(:verify_password).and_return(false)
        end

        it 'does not allow updating without a valid password' do
          fake_user_service.stub(:verify_password).and_return(false)
          put :update, email: 'goo@example.com'

          response.status.should == 401

          body = JSON.parse(response.body)
          body.should == {'error_message' => 'Please correct the following errors and submit the form again:', 'errors' => {'password_error' => ['Current password is incorrect']}}
        end
      end

      context 'when the user cannot be updated' do
        before do
          controller.stub(plink_user_service: fake_user_service)
          fake_user_service.stub(:verify_password).with(10, 'password').and_return(true)
          fake_user_service.stub(:update).with(10, {'email' => 'goo@example.com'})
          .and_return(mock(:plink_user, valid?: false, errors: mock(:errors, messages: ['doesnt work'])))
        end

        it 'updates the user with the given attributes' do
          put :update, email: 'goo@example.com', password: 'password'

          response.status.should == 403
        end

        it 'does not update the email lyris' do
          Lyris::UserService.should_not_receive(:delay)
          put :update, email: 'goo@example.com', password: 'password'
        end
      end
    end
  end

  context 'actions that do not require authentication' do
    describe 'GET login_from_email' do
      it 'calls auto_login_user from AutoLoginExtenstions' do
        controller.should_receive(:auto_login_user).
          with('my_url_token', account_path(random_var: 'herp')).
          and_call_original

        get :login_from_email, user_token: 'my_url_token', random_var: 'herp'
        response.should redirect_to root_url
      end
    end
  end
end
