require 'spec_helper'

describe ContactForm do
  it_behaves_like 'a form backing object'

  describe 'validations' do
    it 'expects an email address to contain an @ sign' do
      subject.email = '@bobo.com'
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

    it 'expects that the message text is not blank' do
      subject.message_text = ' '
      subject.should_not be_valid
      subject.should have(1).error_on(:message_text)
    end
  end
end
