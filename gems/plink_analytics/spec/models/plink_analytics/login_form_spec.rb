require 'spec_helper'

describe PlinkAnalytics::LoginForm do
  let(:form_params) {
    {
      email: 'asd@plink.com',
      password: 'here_is_a_password'
    }
  }

  subject(:login_form) { PlinkAnalytics::LoginForm.new(form_params) }

  describe 'intitialize' do
    it 'takes a hash of form params' do
      login_form.email.should == 'asd@plink.com'
      login_form.password.should == 'here_is_a_password'
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    it 'validates that the contact exists' do
      Plink::ContactRecord.stub(:find_by_email).and_return([])

      login_form.should_not be_valid
      login_form.should have(1).error_on(:email)
    end

    it 'validates that the contact can be authenticated' do
      login_form.stub(:contact_record).and_return(double(authenticate:false))

      login_form.should_not be_valid
      login_form.should have(1).error_on(:password)
    end
  end

  describe '#id' do
    it 'returns the id of the contact_record' do
      login_form.stub(:contact_record).and_return(double(id: 3))

      login_form.id.should == 3
    end
  end
end
