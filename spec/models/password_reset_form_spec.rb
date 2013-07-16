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
    it 'returns true if the password reset is valid' do
      plink_user_service = mock("Plink::UserService", find_by_email: ['user'])
      form = PasswordResetForm.new({email: 'mail@example.com'}, plink_user_service)

      form.save.should == true
    end

    it 'returns false otherwise' do
      plink_user_service = mock("Plink::UserService", find_by_email: nil)
      form = PasswordResetForm.new({email: 'mail@example.com'}, plink_user_service)

      form.save.should == false
    end
  end
end