require 'spec_helper'

describe PasswordResetForm do
  it_behaves_like 'a form backing object'

  describe 'initialize' do
    it 'sets the attributes of the form' do
      form = PasswordResetForm.new(email: 'mail@example.com')

      form.email.should == 'mail@example.com'
    end
  end

  describe 'validation' do
    let(:plink_user_service) { mock("Plink::UserService", find_by_email: nil) }

    it 'returns adds an error when the email is not found' do
      form = PasswordResetForm.new({email: 'mail@example.com'}, plink_user_service)
      form.should have(1).error_on(:base)
    end
  end

  describe '#save' do
    context 'when valid' do
      let(:plink_user_service) { mock("Plink::UserService", find_by_email: mock(:user, first_name: 'Joe')) }
      let(:form) { PasswordResetForm.new({email: 'mail@example.com'}, plink_user_service) }

      it 'returns true if the password reset is valid' do
        form.save.should == true
      end

      it 'sends an email with password reset instructions' do
        fake_mail = mock(:fake_mail)
        fake_mail.should_receive(:deliver)
        PasswordResetMailer.should_receive(:instructions).and_return(fake_mail)

        form.save
      end
    end

    context 'when invalid' do
      let(:plink_user_service) { mock("Plink::UserService", find_by_email: nil) }
      let(:form) { PasswordResetForm.new({email: 'mail@example.com'}, plink_user_service) }

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