require 'spec_helper'

describe GigyaLoginHandlerController do
  describe '#create' do
    let(:gigya_user_stub) { stub }

    before do
      Gigya::User.stub(:from_redirect_params).with({"valid_params" => true}) { gigya_user_stub }
      User.stub(:find_or_create_gigya_user).with(gigya_user_stub) { user_stub }
    end

    context 'when the request is valid and user is found' do
      let(:user_stub) { stub(persisted?: true) }

      it 'signs the user in' do
        controller.should_receive(:sign_in_user).with(user_stub)
        get :create, {valid_params: true}
      end

      it 'redirects the user' do
        controller.stub(:sign_in_user)
        get :create, {valid_params: true}
        response.should be_redirect
      end
    end

    context 'when request is valid but user cannot be persisted' do
      let(:user_stub) { stub(persisted?: false) }

      it 'raises an 404' do
        expect {
          get :create, {valid_params: true}
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end