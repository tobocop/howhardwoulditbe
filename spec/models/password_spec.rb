require 'spec_helper'

describe Password do
  let(:valid_options) { {unhashed_password: "mypassword"} }

  it "must be initialized with an unhashed password" do
    expect { Password.new({}) }.to raise_error(KeyError)
  end

  it "has a UUID salt" do
    SecureRandom.stub(:uuid) { 'my-uuid' }
    password = Password.new(valid_options)

    password.salt.should == 'my-uuid'
  end

  it "caches the salt" do
    password = Password.new(valid_options)
    cached_salt = password.salt

    cached_salt.should == password.salt
  end


  # TODO: Note that the current implementation matches the current ColdFusion implementation
  # which does not rehash a string multiple times. It *does* iterate 1000 times,
  # but it does not use the result as input repeatedly. This should be re-evaluated
  # when we re-evaluate our password generation mechanism.
  it "has a hash constructed using SHA-256" do
    password = Password.new(unhashed_password: "AplaiNTextstrIng55")
    password.stub(:salt) { '6BA943B9-E9E3-8E84-4EDCA75EE2ABA2A5' }

    password.hashed_value.should == 'D7913D231B862AEAD93FADAFB90A90E1A599F0FC08851414FD69C473242DAABD4E6DBD978FBEC1B33995CD2DA58DD1FEA660369E6AE962007162721E9C195192'
  end
end