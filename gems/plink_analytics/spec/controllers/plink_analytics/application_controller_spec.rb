require 'spec_helper'

describe PlinkAnalytics::ApplicationController do
  describe 'current_user' do
    context 'when the session has a contact_id' do
      before do
        session[:contact_id] = 33
      end

      it 'looks up the contact record by id' do
        Plink::ContactRecord.should_receive(:find).with(33)

        controller.current_user
      end
    end

    context 'when the session does not have a contact_id' do
      it 'returns nil' do
        controller.current_user.should be_nil
      end
    end
  end
end
