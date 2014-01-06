require 'spec_helper'

describe 'vw_active_intuit_accounts:remove_oauth_tokens', skip_in_build: true do
  include_context 'rake'

  let!(:user) { create_user }
  let!(:oauth_token) { create_oauth_token(user_id: user.id) }
  let!(:users_institution_account) { create_users_institution_account(user_id: user.id) }

  it 'removes columns associated to the oauth token from the view' do
    Plink::ActiveIntuitAccountRecord.first.oauth_token_id.should == oauth_token.id

    subject.invoke

    Plink::ActiveIntuitAccountRecord.first[:oauth_token_id].should be_nil
  end
end

