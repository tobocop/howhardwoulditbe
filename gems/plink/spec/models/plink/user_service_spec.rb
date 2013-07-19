require 'spec_helper'

describe Plink::UserService do
  describe '#find_by_id' do
    it 'returns the user with the given id' do
      user = create_user
      subject.find_by_id(user.id).should be_instance_of Plink::User
    end

    it 'returns nil if the user is not found' do
      subject.find_by_id(44).should == nil
    end
  end

  describe '#find_by_email' do
    it 'returns the user with the given email if present' do
      user = create_user(email: 'user@example.com')
      subject.find_by_email('user@example.com').should be_instance_of Plink::User
    end

    it 'returns nil if the user cannot be found' do
      subject.find_by_email(33).should == nil
    end
  end

  describe '#update' do
    it 'updates the user record for the given id and returns a user with no errors' do
      user = create_user(first_name: 'Billy')
      returned_user = subject.update(user.id, {first_name: 'Joseph'})

      returned_user.errors.should be_empty

      subject.find_by_id(user.id).first_name.should == 'Joseph'
    end

    it 'returns a user with errors if the user cannot be saved' do
      user = create_user(first_name: 'Billy')
      returned_user = subject.update(user.id, {email: ''})

      returned_user.errors.should_not be_empty
    end
  end

  describe 'update_password' do
    let(:user) { create_user }

    it 'update the password for the user' do
      returned_user = subject.update_password(user.id, {new_password: 'joseph', new_password_confirmation: 'joseph'})

      returned_user.errors.should be_empty
      user.password_hash.should_not == returned_user.password_hash
    end

    it 'does not update if the passwords dont match' do
      returned_user = subject.update_password(user.id, {new_password: 'joseph', new_password_confirmation: 'josep'})

      returned_user.errors.should_not be_empty
      subject.find_by_id(user.id).password_hash.should == user.password_hash
    end
  end

  describe '#verify_password' do
    it 'returns true only if the correct password is given for the correct user' do
      user = create_user(first_name: 'Billy', password: 'pazz123')
      subject.verify_password(user.id, 'pazz123').should be_true

      subject.verify_password(user.id, 'WRONG').should be_false
      subject.verify_password(user.id + 1, 'pazz123').should be_false
    end
  end
end
