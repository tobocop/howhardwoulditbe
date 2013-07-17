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

  describe '#find_by_email' do
    it 'returns the user with the given email if present' do
      user = create_user(email: 'user@example.com')

      subject.find_by_email('user@example.com').should == user
    end

    it 'returns nil if the user cannot be found' do
      subject.find_by_email(33).should == nil
    end
  end

  describe '#update' do
    it 'updates the user record for the given id' do
      user = create_user(first_name: 'Billy')
      subject.update(user.id, {first_name: 'Joseph'})
      subject.find_by_id(user.id).first_name.should == 'Joseph'
    end
  end
end
