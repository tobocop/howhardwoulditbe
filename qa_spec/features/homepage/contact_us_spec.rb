require 'qa_spec_helper'

describe 'Contact Us page', js: true do
  before(:each) do
    visit '/'
  end

  subject { page }

  it 'can be viewed as a guest from the homepage' do
    click_on 'Contact Us'
    current_path.should == '/contact'
  end

  it 'should have the correct fields' do
    visit '/contact'
    page.should have_xpath("//input[@id='contact_form_first_name']")
    page.should have_xpath("//input[@id='contact_form_last_name']")
    page.should have_xpath("//input[@id='contact_form_email']")
    
    page.should have_xpath("//input[@id='contact_form_category_customer_support']")
    page.should have_xpath("//input[@id='contact_form_category_close_my_account']")
    page.should have_xpath("//input[@id='contact_form_category_advertising_and_business_development']")
    page.should have_xpath("//input[@id='contact_form_category_investor_relations']")

    page.should have_xpath("//textarea[@id='contact_form_message_text']")
  end

  it 'should have the correct placeholder text' do
    visit '/contact'
    page.should have_xpath("//input[@placeholder='First Name']")
    page.should have_xpath("//input[@placeholder='Last Name']")
    page.should have_xpath("//input[@placeholder='Email']")
  end

  context 'form valiations:' do
    it 'shouldnt submit if first name is blank' do
      visit '/contact'
      fill_in 'Last Name', with: 'Last'
      fill_in 'Email', with: 'test@plink.com'
      within '.new_contact_form' do
        click_on 'Contact Us'
      end
      page.should have_text("First name can't be blank")
    end

    it 'shouldnt submit if last name is blank' do
      visit '/contact'
      fill_in 'First Name', with: 'First'
      fill_in 'Email', with: 'test@plink.com'
      within '.new_contact_form' do
        click_on 'Contact Us'
      end
      page.should have_text("Last name can't be blank")
    end

    it 'shouldnt submit if email is blank' do
      visit '/contact'
      fill_in 'First Name', with: 'First'
      fill_in 'Last Name', with: 'Last'
      within '.new_contact_form' do
        click_on 'Contact Us'
      end
      page.should have_text("Email can't be blank")
    end
  end

  it 'should submit successfully if all fields are filled out' do
    visit '/contact'
    fill_in 'First Name', with: 'First'
    fill_in 'Last Name', with: 'Last'
    fill_in 'Email', with: 'test@plink.com'
    within '.new_contact_form' do
      click_on 'Contact Us'
    end
    current_path.should == '/contact/thank_you'
    page.should have_text 'Thank you for contacting us.'
  end
end

