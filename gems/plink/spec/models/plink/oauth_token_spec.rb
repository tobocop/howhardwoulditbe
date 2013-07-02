require 'spec_helper'

describe Plink::OauthToken do

  let(:valid_params) {
    {
      encrypted_oauth_token: 'derp',
      encrypted_oauth_token_secret: 'derp_secret',
      oauth_token_iv: 'derp_iv',
      oauth_token_secret_iv: 'derp_secret_iv',
      user_id: 1,
      is_active: true
    }
  }

  subject { Plink::OauthToken.new(valid_params) }

  it 'should be persisted' do
    Plink::OauthToken.create(valid_params).should be_persisted
  end

end
