require 'spec_helper'

describe UserRegistrationForm do

  subject { UserRegistrationForm.new(password: 'goodpassword', password_confirmation: 'goodpassword', first_name: 'Bobo', email: 'bobo@example.com') }

  it 'is not persisted' do
    subject.should_not be_persisted
  end

  describe 'validation' do
    it 'is valid' do
      subject.should be_valid
    end

    it 'expects a password to have at least 6 characters' do
      subject.password = 'foo12'
      subject.password_confirmation = 'foo12'
      subject.should_not be_valid
      subject.should have(1).error_on(:password)
    end

    it 'expects password confirmation field to match the entered unhashed password' do
      subject.password = 'goodpassword'
      subject.password_confirmation = 'wontmatch'
      subject.should_not be_valid
      subject.should have(1).error_on(:password)
    end

    it 'expects a first name to be entered' do
      subject.first_name = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:first_name)
    end

    it 'expects email address to be present' do
      subject.email = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it 'expects an email address to contain an @ sign' do
      subject.email = 'bobo.com'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it 'expects an email address to have a username and domain' do
      subject.email = 'bobo@'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it 'expects an email address not to have a + sign' do
      subject.email = 'bobo+12@example.com'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it 'does not let you register with a email address already in the DB' do
      user = create_user

      subject.email = user.email
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it 'is not valid if the options passed to User are invalid' do
      Plink::UserCreationService.any_instance.stub(:valid?).and_return(false)
      Plink::UserCreationService.any_instance.stub(:errors) { {:foo => 'dummy error'} }

      subject.should_not be_valid
      subject.should have(1).error_on(:foo)
      subject.errors[:foo].first.should == 'dummy error'
    end

    it 'provides a user_creation_service object after validation' do
      subject.valid?
      subject.user_creation_service.should be_a(Plink::UserCreationService)
    end

    it 'can provide a user_id #needs refactoring' do
      Plink::UserCreationService.any_instance.stub(:user_id).and_return(123)
      subject.valid?
      subject.user_id.should == 123
    end

  end

  describe 'saving' do
    #before { Plink::WalletCreationService.stub(:new) { stub(create_for_user_id: true) } }

    it 'calls save on the user_creation_service when valid' do
      password = stub(hashed_value: '1234790dfghjkl;', salt: 'qwer-qwer-qwer-qwer')
      Password.stub(:new).with(unhashed_password: 'goodpassword') { password }
      user_creation_service_mock = mock(valid?:true)
      Plink::UserCreationService.should_receive(:new).with(password_hash: '1234790dfghjkl;', first_name: 'Bobo', email: 'bobo@example.com', salt: 'qwer-qwer-qwer-qwer').and_return(user_creation_service_mock)
      user_creation_service_mock.should_receive(:create_user)

      subject.save.should be_true
    end

    it 'does not create a user object if validation fails' do
      subject.stub(:valid?) { false }
      subject.save.should be_false
    end
  end
end