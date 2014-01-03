require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_user_service'

describe PasswordResetForm do
  it_behaves_like "a form backing object"

  let(:valid_params) { {new_password: 'pazzword', new_password_confirmation: 'pazzword', token: 'bees'} }
  let(:password_reset) { double(token: 'abc-123', user_id: 9, created_at: 1.hour.ago) }

  describe '#save' do
    context 'when the password reset is successful' do
      let(:user) { double(:user, id: 9) }
      let(:password) { double(:password, salt: 'pepper', hashed_value: 'ee44-hheu') }
      let(:plink_user_service) { Plink::FakeUserService.new({9 => user}) }

      before do
        Plink::UserService.stub(:new).and_return(plink_user_service)
      end

      it 'allows the user to reset their password' do
        PasswordReset.should_receive(:where).with(token: 'abc-123').and_return([password_reset])
        Plink::Password.should_receive(:new).with(unhashed_password: 'pazzword').and_return(password)
        plink_user_service.should_receive(:update).with(9, {password_hash: 'ee44-hheu', salt: 'pepper'}).and_return(true)

        password_reset_form = PasswordResetForm.new(token: 'abc-123', new_password: 'pazzword', new_password_confirmation: 'pazzword')

        password_reset_form.save.should == true
      end
    end

    context 'when the password reset is not successful' do
      let(:password_reset) { double(token: 'abc-123', user_id: 9) }

      it 'returns false' do
        PasswordReset.should_receive(:where).with(token: 'abc-123').and_return([])

        password_reset_form = PasswordResetForm.new(token: 'abc-123', new_password: 'pazzword', new_password_confirmation: 'pazzword')

        password_reset_form.save.should == false
      end
    end
  end

  describe 'validations' do
    it 'can be valid when when a token is given if a corresponding password reset can be found' do
      PasswordReset.stub(:where).and_return([password_reset])

      password_reset_form = PasswordResetForm.new(valid_params)

      password_reset_form.valid?.should be_true
    end

    it 'is invalid if the password reset is more than 24 hours old' do
      expired_password_reset = double(:password_reset, token: 'abc-123', user_id: 9, created_at: 25.hours.ago)
      PasswordReset.stub(:where).and_return([expired_password_reset])

      password_reset_form = PasswordResetForm.new(valid_params)

      password_reset_form.valid?.should == false
      password_reset_form.errors.full_messages.should == ['Sorry, the reset password link has expired.  Please visit the login screen and request a new reset password link.']
    end

    it 'is invalid if the password is less than 6 characters' do
      PasswordReset.stub(:where).and_return([password_reset])

      password_reset = PasswordResetForm.new(valid_params.merge(new_password: '12345', new_password_confirmation: '12345'))
      password_reset.should_not be_valid
      password_reset.errors.full_messages.should == ["New password is too short (minimum is 6 characters)"]
    end

    it 'is invalid if given a token and no password reset can be found' do
      PasswordReset.stub(:where).and_return([])
      password_reset_form = PasswordResetForm.new(new_password: 'pazzword', new_password_confirmation: 'pazzword', token: 'token')
      password_reset_form.should_not be_valid
      password_reset_form.errors.full_messages.should == ['Sorry, this link is invalid.']
    end

    it 'validates that password and confirmation are the same' do
      PasswordReset.stub(:where).and_return([password_reset])

      password_reset_form = PasswordResetForm.new(new_password: 'pazzword', new_password_confirmation: 'pppppzzzz', token: 'token')
      password_reset_form.valid?.should be_false
      password_reset_form.errors.full_messages.should == ["New password doesn't match confirmation"]
    end
  end
end
