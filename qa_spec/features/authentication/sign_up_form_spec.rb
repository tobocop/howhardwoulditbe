require 'qa_spec_helper'

describe 'Signing up', js: true do

  it 'lets the user sign up with the regular registration form' do
    sign_up_user('Matt', 'test@plink.com', 'test123')
    page.should have_text('Welcome, Matt!')
    current_path.should == '/wallet'
  end

  it 'tells the user their password is too short' do
    sign_up_user('Matt', 'test@plink.com', 'test')
    page.should have_text('Please enter a password at least 6 characters long')
    page.should have_link("Having trouble? Contact Us")
  end

  it "tells the user to enter a password confirmation" do
    sign_up_user('Matt', 'test@plink.com', 'test123', '')
    page.should have_text('Please confirm your password')
    page.should have_link("Having trouble? Contact Us")
  end

  it "tells the user the password fields don't match" do
    sign_up_user('Matt', 'test@plink.com', 'test123', 'test345')
    page.should have_text('Confirmation password doesn\'t match')
    page.should have_link("Having trouble? Contact Us")
  end

  it 'tells the user the first name field is blank' do
    sign_up_user('', 'test@plink.com', 'test123', 'test123')
    page.should have_text('Please provide a First name')
    page.should have_link("Having trouble? Contact Us")
  end

  it 'tells the user the email field is blank' do
    sign_up_user('Matt', '', 'test123', 'test123')
    page.should have_text('Please enter a valid email address')
    page.should have_link("Having trouble? Contact Us")
  end

  it 'tells the user the email field is invalid format' do
    sign_up_user('Matt', 'notarealemail', 'test123', 'test123')
    page.should have_text('Please enter a valid email address')
    page.should have_link("Having trouble? Contact Us")
  end

  context 'when the user already exists in the DB' do
    before(:each) do
      user = create_user( email: 'test@plink.com', password: 'test123', first_name: 'Matt')
      wallet = create_wallet(user_id: user.id)
   end

    it 'tells the user that an email already exists in the database' do
      sign_up_user('Matt', 'test@plink.com', 'test123', 'test123')
      page.should have_text("You've entered an email address that is already registered with Plink.")
      page.should have_link("Having trouble? Contact Us")
    end
  end
end
