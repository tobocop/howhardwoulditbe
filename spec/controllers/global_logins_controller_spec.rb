require 'spec_helper'

describe GlobalLoginsController do
  it_should_behave_like(:tracking_extensions)

  describe 'GET new' do
    let!(:valid_user) { create_user(email: 'waltermitty@example.com') }
    let(:valid_token) { 'pocketa-pocketa' }
    let(:valid_token_record) do
      double(
        id: 1,
        expires_at: 5.days.from_now.to_date,
        redirect_url: '/contests',
        token: valid_token
      )
    end

    context 'with valid auto login URL parameters' do
      it 'logs the user in automatically if the user is not currently logged in' do
        Plink::GlobalLoginTokenRecord.stub(existing: [valid_token_record])

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        controller.user_logged_in?.should be_true
      end

      it 'redirects the user to the correct URL specified in the global login token table' do
        Plink::GlobalLoginTokenRecord.stub(existing: [valid_token_record])

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        response.should redirect_to '/contests'
      end

      it 'does not sign in the user if the user is already logged in' do
        Plink::GlobalLoginTokenRecord.stub(existing: [valid_token_record])
        controller.stub(current_virtual_currency: double(:virtual_currency, subdomain: 'www'))
        controller.stub(current_user: double(:logged_in_user, logged_in?: true, id: 1, primary_virtual_currency_id: 3))

        controller.should_not_receive(:sign_in_user)

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token
      end

      it 'does not display an error message if the user is already logged in' do
        Plink::GlobalLoginTokenRecord.stub(existing: [valid_token_record])
        controller.stub(current_virtual_currency: double(:virtual_currency, subdomain: 'www'))
        controller.stub(current_user: double(:logged_in_user, logged_in?: true, id: 1, primary_virtual_currency_id: 3))

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        flash[:error].should be_nil
      end

      it 'redirects the user to the correct destination if the user is already logged in' do
        Plink::GlobalLoginTokenRecord.stub(existing: [valid_token_record])
        controller.sign_in_user(valid_user)
        controller.stub(current_virtual_currency: double(:virtual_currency, subdomain: 'www'))

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        response.should redirect_to '/contests'
      end
    end

    context 'with an invalid auto_login URL' do
      it 'does not log in the user if the provided global token is incorrect' do
        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: 'invalid'

        controller.user_logged_in?.should be_false
      end

      it 'does not log in the user if the provided global token is expired' do
        Plink::GlobalLoginTokenRecord.stub(existing: [])

        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        controller.user_logged_in?.should be_false
       end

      it 'does not log in the user if the provided user token is incorrect' do
        get :new, user_token: 'invalid', uid: valid_user.id, global_token: valid_token

        controller.user_logged_in?.should be_false
      end

      it 'does not log in the user if the provided global token is missing' do
        get :new, user_token: valid_user.login_token, uid: valid_user.id, global_token: valid_token

        controller.user_logged_in?.should be_false
      end

      it 'does not log in the user if the provided user token is missing' do
        get :new, uid: valid_user.id, global_token: valid_token

        controller.user_logged_in?.should be_false
      end

      it 'does not log in the user if the provided uid parameter is missing' do
        get :new, user_token: 'invalid', global_token: valid_token

        controller.user_logged_in?.should be_false
      end

      it 'redirects the user to the home page' do
        get :new, user_token: 'invalid', uid: valid_user.id, global_token: valid_token

        response.should redirect_to(root_url)
      end

      it 'shows a flash message with the text "Link expired." for an invalid login URL' do
        get :new, user_token: 'invalid', uid: valid_user.id, global_token: valid_token

        flash[:error].should == 'Link expired.'
      end

      it 'does not log in the user if the user hash is not found' do
        get :new, user_token: valid_user.login_token, uid: 9036455, global_token: valid_token

        controller.user_logged_in?.should be_false
      end
    end
  end
end
