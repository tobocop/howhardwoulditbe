require 'spec_helper'

describe Gigya::Signature do
  let(:uid) { '_guid_LVzJyCySlXIIYbb0Yjw897NKsqvVas8HUhpmStc7zKE=' }
  let(:uid_signature) { '7HA9q0rSzfsz16ox53Wc7z4XasA=' }
  let(:known_timestamp) { 1371659634 }
  let(:valid_options) { {UID: uid, UIDSignature: uid_signature, signatureTimestamp: known_timestamp} }

  before do
    sixty_seconds_after_timestamp = Time.at(known_timestamp + 60)
    Time.stub(:now) { sixty_seconds_after_timestamp }
  end

  context 'when the secret is good' do
    subject { Gigya::Signature.new(valid_options) }

    before do
      subject.stub(:secret) { "Eel7j5UvqEjMzGH6tiHArB7CV7GNhMOkl6+vSh7PecQ=" }
    end

    it 'is valid' do
      subject.should be_valid
    end

    it 'has a signature timestamp' do
      subject.signature_timestamp.should == known_timestamp
    end

    it 'has a uid_signature' do
      subject.uid_signature.should == uid_signature
    end

    it 'has a uid' do
      subject.uid.should == uid
    end

    it 'has a signature' do
      subject.computed_signature.should == uid_signature
    end
  end

  context 'with valid parameters' do
    let(:less_than_three_minutes_ago) { Time.now.to_i - 179 }

    it 'has a valid signature when timestamp is less than three minutes old' do
      Gigya::Signature.new(valid_options.merge(signatureTimestamp: less_than_three_minutes_ago)).should have_recent_timestamp
    end
  end

  describe 'invalid cases' do
    it 'is invalid when the timestamp is not in the last three minutes' do
      more_than_three_minutes_ago = Time.now.to_i - 181 # seconds
      Gigya::Signature.new(signatureTimestamp: more_than_three_minutes_ago).should_not be_valid
    end

    it 'is invalid when secret is bad' do
      request = Gigya::Signature.new(valid_options)
      request.stub(:secret) { "bad_secret" }
      request.should_not be_valid
    end
  end

end