require 'spec_helper'

describe PasswordResetForm do
  it_behaves_like "a form backing object"

  let(:mock_password_reset) { mock(token: 'abc-123', user_id: 9) }

  describe '#save' do
    context 'when the password reset is successful' do
      let(:mock_user) { mock(:user) }
      let(:mock_password) { mock(:mock_password, salt: 'pepper', hashed_value: 'ee44-hheu')}

      it 'allows the user to reset their password' do
        PasswordReset.should_receive(:where).with(token: 'abc-123').and_return([mock_password_reset])
        Plink::UserService.any_instance.should_receive(:find_by_id).with(9).and_return(mock_user)

        Password.should_receive(:new).with(unhashed_password: 'pazzword').and_return(mock_password)

        mock_user.should_receive(:update_attributes).with(password_hash: 'ee44-hheu', salt: 'pepper').and_return(true)

        password_reset_form = PasswordResetForm.new(token: 'abc-123', new_password: 'pazzword', new_password_confirmation: 'pazzword')

        password_reset_form.save.should == true
      end
    end

    context 'when the password reset is not successful' do
      let(:mock_password_reset) { mock(token: 'abc-123', user_id: 9) }

      it 'returns false' do
        PasswordReset.should_receive(:where).with(token: 'abc-123').and_return([])

        password_reset_form = PasswordResetForm.new(token: 'abc-123', new_password: 'pazzword', new_password_confirmation: 'pazzword')

        password_reset_form.save.should == false
      end
    end
  end

  describe 'validations' do
    it 'can be valid when when a token is given if a corresponding password reset can be found' do
      PasswordReset.stub(:where).and_return([mock_password_reset])

      password_reset_form = PasswordResetForm.new(new_password: 'pazzword', new_password_confirmation: 'pazzword', token: 'bees')

      password_reset_form.valid?.should be_true
    end

    it 'is invalid if given a token and no password reset can be found' do
      PasswordReset.stub(:where).and_return([])
      password_reset_form = PasswordResetForm.new(new_password: 'pazzword', new_password_confirmation: 'pazzword', token: 'token')
      password_reset_form.should_not be_valid
      password_reset_form.errors.full_messages.should == ['Password reset link is invalid']
    end

    it 'validates that password and confirmation are the same' do
      PasswordReset.stub(:where).and_return([mock_password_reset])

      password_reset_form = PasswordResetForm.new(new_password: 'pazzword', new_password_confirmation: 'pppppzzzz', token: 'token')
      password_reset_form.valid?.should be_false
      password_reset_form.errors.full_messages.should == ["New password doesn't match confirmation"]
    end
  end
end
