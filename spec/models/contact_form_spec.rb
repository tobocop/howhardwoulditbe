require 'spec_helper'

describe ContactForm do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  before do
    @model = subject
  end

  ActiveModel::Lint::Tests.public_instance_methods.map { |method| method.to_s }.grep(/^test/).each do |method|
    example(method.gsub('_', ' ')) { send method }
  end

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
  end
end