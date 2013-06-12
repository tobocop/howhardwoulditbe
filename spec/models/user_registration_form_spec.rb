require 'spec_helper'

describe "user_registration_form" do

  subject { UserRegistrationForm.new(unhashed_password: "goodpassword", password_confirmation: "goodpassword", first_name: "Bobo", email: "bobo@example.com") }

  it "is not persisted" do
    subject.should_not be_persisted
  end

  describe "validation" do
    it "is valid" do
      subject.should be_valid
    end

    it "expects a password to have at least 6 characters" do
      subject.unhashed_password = 'foo12'
      subject.unhashed_password_confirmation = 'foo12'
      subject.should_not be_valid
      subject.should have(1).error_on(:unhashed_password)
    end

    it "expects password confirmation field to match the entered unhashed password" do
      subject.unhashed_password = 'goodpassword'
      subject.unhashed_password_confirmation = 'wontmatch'
      subject.should_not be_valid
      subject.should have(1).error_on(:unhashed_password)
    end

    it "expects a first name to be entered" do
      subject.first_name = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:first_name)
    end

    it "expects email address to be present" do
      subject.email = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it "expects an email address to contain an @ sign" do
      subject.email = 'bobo.com'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it "expects an email address to have a username and domain" do
      subject.email = 'bobo@'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it "expects an email address not to have a + sign" do
      subject.email = 'bobo+12@example.com'
      subject.should_not be_valid
      subject.should have(1).error_on(:email)
    end

    it "is not valid if the options passed to User are invalid" do
      User.any_instance.stub(:valid?).and_return(false)
      User.any_instance.stub(:errors) { {:foo => "dummy error"} }

      subject.should_not be_valid
      subject.should have(1).error_on(:foo)
      subject.errors[:foo].first.should == "dummy error"
    end
  end

  describe "saving" do
    it "creates a user object when valid" do
      password = stub(hashed_value: '1234790dfghjkl;', salt: 'qwer-qwer-qwer-qwer')
      Password.stub(:new).with(unhashed_password: "goodpassword") { password }

      user_mock = mock_model(User, save: true)
      User.should_receive(:new).with(password: "1234790dfghjkl;", first_name: "Bobo", email: "bobo@example.com", salt: "qwer-qwer-qwer-qwer").and_return(user_mock)
      subject.save.should be_true
    end

    it "does not create a user object if validation fails" do
      subject.stub(:valid?) { false }
      subject.save.should be_false
    end
  end
end