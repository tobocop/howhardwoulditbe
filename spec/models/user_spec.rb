require 'spec_helper'

describe User do
  #before do
  #  User.create(emailAddress: 'joe@example.com')
  #end

  it 'should work' do
    User.count.should == 1
  end
end
