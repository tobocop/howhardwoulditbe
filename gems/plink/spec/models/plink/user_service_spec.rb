require 'spec_helper'

describe Plink::UserService do
  describe '#find_by_id' do
    it 'returns the user with the given id' do
      user = create_user

      subject.find_by_id(user.id).should == user
    end

    it 'returns nil if the user is not found' do
      subject.find_by_id(44).should == nil
    end
  end
end
