require 'qa_spec_helper'

describe 'Contact Us page', js: true do
  before { create_virtual_currency(name: 'Plink Points', subdomain: 'www') }

  subject { page }

  context 'as a guest' do
    before(:each) do
      visit '/'
      click_on('Contact Us', match: :first)
    end

    it 'can be viewed from the homepage' do
      current_path.should == '/contact'
      page.should have_text('Contact Us')
      page.should have_text('How can we help you?')
    end

    it 'should have the correct fields' do
      page.should have_field('contact_form[first_name]')
      page.should have_field('contact_form[last_name]')
      page.should have_field('contact_form[email]')
      page.should have_field('contact_form[message_text]')
      page.should have_button('Submit')

      page.should have_field('contact_form_category_customer_support')
      page.should have_field('contact_form_category_advertising_and_business_development')
      page.should have_field('contact_form_category_investor_relations')
      page.should have_field('contact_form_category_other')
    end

    it 'should have the correct placeholder text' do
      visit '/contact'
      page.should have_xpath("//input[@placeholder='First Name']")
      page.should have_xpath("//input[@placeholder='Last Name']")
      page.should have_xpath("//input[@placeholder='Email']")
    end

    context 'form' do

      it 'shouldnt submit if first name is blank' do
        submit_contact_us_form('', 'Tester', 'non@member.com',
          'Im a lumberjack and im ok I sleep all night and work all day')
        page.current_path.should == '/contact'
        page.should have_text("First name can't be blank")
      end

      it 'shouldnt submit if last name is blank' do
        submit_contact_us_form('Matt', '', 'non@member.com',
          'Im a lumberjack and im ok I sleep all night and work all day')
        page.current_path.should == '/contact'
        page.should have_text("Last name can't be blank")
      end

      it 'shouldnt submit if email is blank' do
        submit_contact_us_form('Matt', 'Tester', '',
          'Im a lumberjack and im ok I sleep all night and work all day')
        page.current_path.should == '/contact'
        page.should have_text("Email can't be blank")
      end

      it 'shouldnt submit if an email is invalid' do
        submit_contact_us_form('Matt', 'Tester', 'invalidemailformat',
          'Im a lumberjack and im ok I sleep all night and work all day')
        page.current_path.should == '/contact'
        page.should have_text("Please enter a valid email address")
      end

      it 'should submit successfully for a non-member' do
        submit_contact_us_form('Matt', 'Tester', 'non@member.com',
          'Im a lumberjack and im ok I sleep all night and work all day')
        page.current_path.should == '/'
        page.should have_text('Thank you for contacting Plink.')
      end

      pending 'bug fix' do
        it 'shouldnt submit if message is blank' do
          submit_contact_us_form('Matt', 'Tester', 'test@email.com', '')
          page.current_path.should == '/contact'
          page.should have_text("Message text can't be blank")
        end
      end
    end
  end

  context 'as a linked user' do
    before(:each) do
      user = create_user( email: 'email@plink.com', password: 'test123', first_name: 'tester')
      wallet = create_wallet(user_id: user.id)
    end

    it 'should submit successfully and redirect to the wallet' do
      sign_in('email@plink.com', 'test123')
      sleep 1
      click_on('Contact Us', match: :first)
      submit_contact_us_form('Matt', 'Tester', 'non@member.com',
        'Im a lumberjack and im ok I sleep all night and work all day')
      page.current_path.should == '/wallet'
      page.should have_text('Thank you for contacting Plink.')
    end
  end
end
