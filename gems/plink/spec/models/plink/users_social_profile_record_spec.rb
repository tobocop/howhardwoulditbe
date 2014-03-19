require 'spec_helper'

describe Plink::UsersSocialProfileRecord do
  it { should allow_mass_assignment_of(:profile)}
  it { should allow_mass_assignment_of(:user_id)}

  let(:real_social_profile) {%q{{  "identities": [    {      "likes": [{ "id":"111065157857", "name":"The Pioneer Woman - Ree Drummond", "category":"Author", "time":"2014-02-18T19:58:28.0000000Z", "timestamp":1392753508 }],      "oldestDataUpdatedTimestamp": 1392229244639    },    {      "provider": "site",      "oldestDataUpdatedTimestamp": 1392847893948    }  ],  "likes": [{ "id":"345949688881490", "name":"The Crazies Corner", "category":"Just for fun", "time":"2014-02-17T20:40:21.0000000Z", "timestamp":1392669621 }],  "work": [{ "company":"Amazon.com", "companyID":"9465008123" }, { "company":"Whirlpool USA", "companyID":"152290218141343" }]}} }
  let(:valid_params) {
    {
      profile: '{"some":2, "json":3}',
      user_id: 12
    }
  }

  it 'can be persisted' do
    Plink::UsersSocialProfileRecord.create(valid_params).should be_persisted
  end

  describe '#likes' do
    it 'returns only the likes portion of the social profile in a string' do
      users_social_profile = Plink::UsersSocialProfileRecord.new(valid_params.merge(profile: real_social_profile))
      users_social_profile.likes.should == JSON.parse(%q{[{"id":"345949688881490","name":"The Crazies Corner","category":"Just for fun","time":"2014-02-17T20:40:21.0000000Z","timestamp":1392669621}]})
    end

    it 'returns a blank array if no likes are found' do
      users_social_profile = Plink::UsersSocialProfileRecord.new(valid_params)
      users_social_profile.likes.should == []
    end
  end
end
