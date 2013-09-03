require 'spec_helper'

describe PasswordResetRequestForm do
  it_behaves_like 'a form backing object'

  describe 'initialize' do
    it 'sets the attributes of the form' do
      form = PasswordResetRequestForm.new(email: 'mail@example.com')

      form.email.should == 'mail@example.com'
    end
  end

  describe 'validation' do
    let(:plink_user_service) { mock("Plink::UserService", find_by_email: nil) }

    it 'returns an error when the email is not found' do
      form = PasswordResetRequestForm.new({email: 'mail@example.com'}, plink_user_service)
      form.should_not be_valid
      form.should have(1).error_on(:user)
    end

    it 'returns an error when the email is in an invalid format' do
      form = PasswordResetRequestForm.new({email: 'invalid+plink@example.com'}, plink_user_service)
      form.should_not be_valid
      form.should have(1).error_on(:email)
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:plink_user_service) { mock("Plink::UserService", find_by_email: mock(:user, first_name: 'Joe', id: 3, valid?: true)) }
      let(:form) { PasswordResetRequestForm.new({email: 'mail@example.com'}, plink_user_service) }
      let(:mock_password_reset) { mock(:password_reset, token: 'token') }

      before do
        PasswordReset.stub(build: mock_password_reset)
      end

      it 'returns true if the password reset is valid' do
        form.save.should == true
      end

      it 'sends an email to the user with a link to reset password' do
        fake_mail = mock(:fake_mail)
        fake_mail.should_receive(:deliver)
        PasswordResetMailer.should_receive(:instructions).with('mail@example.com', 'Joe', 'token').and_return(fake_mail)

        form.save
      end

      it 'create a password reset record' do
        PasswordReset.should_receive(:build).with(user_id: 3).and_return(mock_password_reset)

        form.save
      end
    end

    context 'when invalid' do
      let(:plink_user_service) { mock("Plink::UserService", find_by_email: nil) }
      let(:form) { PasswordResetRequestForm.new({email: 'mail@example.com'}, plink_user_service) }

      it 'returns false otherwise' do
        form.save.should == false
      end

      it 'does not send an email' do
        form.save

        ActionMailer::Base.deliveries.count.should == 0
      end
    end
  end
end
