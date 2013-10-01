require 'spec_helper'

describe UserRegistrationForm do
  let(:form_params) {
    {
      password: 'goodpassword',
      password_confirmation: 'goodpassword',
      first_name: 'Bobo',
      email: 'bobo@example.com',
      virtual_currency_name: 'Plink Points',
      provider: 'organic',
      ip: '127.1.1.1'
    }
  }

  subject(:user_registration_form) { UserRegistrationForm.new(form_params) }

  it 'is not persisted' do
    user_registration_form.should_not be_persisted
  end

  describe 'validation' do
    it 'is valid' do
      user_registration_form.should be_valid
    end

    it 'expects a password to have at least 6 characters' do
      user_registration_form.password = 'foo12'
      user_registration_form.password_confirmation = 'foo12'
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:password)
    end

    it 'expects password confirmation field to match the entered unhashed password' do
      user_registration_form.password = 'goodpassword'
      user_registration_form.password_confirmation = 'wontmatch'
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:password)
    end

    it 'expects a first name to be entered' do
      user_registration_form.first_name = nil
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:first_name)
    end

    it 'expects email address to be present' do
      user_registration_form.email = nil
      user_registration_form.should_not be_valid
      user_registration_form.should have(2).error_on(:email)
    end

    it 'expects an email address to contain an @ sign' do
      user_registration_form.email = 'bobo.com'
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:email)
    end

    it 'expects an email address to have a username and domain' do
      user_registration_form.email = 'bobo@'
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:email)
    end

    it 'expects an email address not to have a + sign' do
      user_registration_form.email = 'bobo+12@example.com'
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:email)
    end

    it 'does not let you register with a email address already in the DB' do
      user = create_user

      user_registration_form.email = user.email
      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:email)
    end

    it 'expects a provider' do
      user_registration_form.provider = ' '

      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:provider)
    end

    it 'is not valid if the options passed to User are invalid' do
      Plink::UserCreationService.any_instance.stub(:valid?).and_return(false)
      Plink::UserCreationService.any_instance.stub(:errors) { {:foo => 'dummy error'} }

      user_registration_form.should_not be_valid
      user_registration_form.should have(1).error_on(:foo)
      user_registration_form.errors[:foo].first.should == 'dummy error'
    end

    it 'provides a user_creation_service object after validation' do
      user_registration_form.valid?
      user_registration_form.user_creation_service.should be_a(Plink::UserCreationService)
    end

    it 'can provide a user_id #needs refactoring' do
      Plink::UserCreationService.any_instance.stub(:user_id).and_return(123)
      user_registration_form.valid?
      user_registration_form.user_id.should == 123
    end
  end

  describe 'saving' do
    context 'when successful' do
      let(:user_creation_service_mock) { mock(:user_creation_service, valid?: true) }
      let(:mock_mail) {mock(:welcome_email)}

      before do
        password = mock(:password, hashed_value: '1234790dfghjkl;', salt: 'qwer-qwer-qwer-qwer')
        Plink::Password.stub(:new).with(unhashed_password: 'goodpassword') { password }

        user_params = {
          password_hash: '1234790dfghjkl;',
          first_name: 'Bobo',
          email: 'bobo@example.com',
          salt: 'qwer-qwer-qwer-qwer',
          provider: 'organic',
          ip: '127.1.1.1'
        }
        Plink::UserCreationService.stub(:new).with(user_params).and_return(user_creation_service_mock)

        user_mock = mock(:user, id: 14, email: 'bobo@example.com', first_name: 'Bobo')
        user_creation_service_mock.stub(:create_user).and_return(user_mock)

        mock_delay = double('mock_delay').as_null_object
        AfterUserRegistration.stub(:delay).and_return(mock_delay)
      end

      it 'calls save on the user_creation_service when valid' do
        user_params = {
          password_hash: '1234790dfghjkl;',
          first_name: 'Bobo',
          email: 'bobo@example.com',
          salt: 'qwer-qwer-qwer-qwer',
          provider: 'organic',
          ip: '127.1.1.1'
        }
        Plink::UserCreationService.should_receive(:new).with(user_params).
          and_return(user_creation_service_mock)

        user_mock = mock(:user,
          email: 'bobo@example.com', first_name: 'Bobo', id: 3)

        user_creation_service_mock.should_receive(:create_user).and_return(user_mock)

        user_registration_form.save.should be_true
      end

      it 'does not email the user a welcome email' do
        user_params = {
          email: 'bobo@example.com',
          first_name: 'Bobo',
          virtual_currency_name: 'Plink Points'
        }

        UserRegistrationMailer.should_not_receive(:welcome).with(user_params)

      it 'delays sending a complete your registration email' do
        mock_delay = double('mock_delay').as_null_object
        AfterUserRegistration.should_receive(:delay).and_return(mock_delay)
        mock_delay.should_receive(:send_complete_your_registration_email).with(14)

        user_registration_form.save
      end
    end

    it 'does not create a user object if validation fails' do
      user_registration_form.stub(:valid?) { false }
      user_registration_form.save.should be_false
    end
  end
end
