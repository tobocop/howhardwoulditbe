require 'spec_helper'

describe 'Static pages' do
  before { create_virtual_currency }
  before { create_contest }

  it 'can be reached from the footer' do
    visit '/'

    within '.footer' do
      click_on 'FAQ'
    end

    page.should have_content 'FAQ'

    within '.footer' do
      click_on 'Terms of Service'
    end

    page.should have_content 'Service Terms'

    within '.footer' do
      click_on 'Careers'
    end

    page.should have_content 'Careers'
  end

  context 'Contact Us page' do
    context 'as a guest' do
      before(:each) do
        visit '/'
        click_on('Contact Us', match: :first)
      end

      it 'can be viewed from the homepage' do
        current_path.should == contact_path
        page.should have_text('Contact Us')
        page.should have_text('How can we help you?')
      end

      it 'has the correct fields' do
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

      it 'has the correct placeholder text' do
        visit contact_path
        page.should have_xpath("//input[@placeholder='First Name']")
        page.should have_xpath("//input[@placeholder='Last Name']")
        page.should have_xpath("//input[@placeholder='Email']")
      end

      context 'form' do
        it 'will not submit if first name is blank' do
          submit_contact_us_form('', 'Tester', 'non@member.com',
            'Im a lumberjack and im ok I sleep all night and work all day')
          page.current_path.should == contact_path
          page.should have_text('Please provide your first name')
        end

        it 'will not submit if last name is blank' do
          submit_contact_us_form('Matt', '', 'non@member.com',
            'Im a lumberjack and im ok I sleep all night and work all day')
          page.current_path.should == contact_path
          page.should have_text('Please provide your last name')
        end

        it 'will not submit if email is blank' do
          submit_contact_us_form('Matt', 'Tester', '',
            'Im a lumberjack and im ok I sleep all night and work all day')
          page.current_path.should == contact_path
          page.should have_text('Please provide your Plink registered email')
        end

        it 'will not submit if an email is invalid' do
          submit_contact_us_form('Matt', 'Tester', 'invalidemailformat',
            'Im a lumberjack and im ok I sleep all night and work all day')
          page.current_path.should == contact_path
          page.should have_text('Please enter a valid email')
          page.should_not have_text('EmailPlease enter a valid email')
        end

        it 'will not submit if message is blank' do
          submit_contact_us_form('Matt', 'Tester', 'test@email.com', '')
          page.current_path.should == contact_path
          page.should have_text('Please provide a brief message so we can better assist you')
        end

        it 'submits successfully for a non-member' do
          submit_contact_us_form('Matt', 'Tester', 'non@member.com',
            'Im a lumberjack and im ok I sleep all night and work all day')
          page.current_path.should == '/'
          page.should have_text('Thank you for contacting Plink.')
        end
      end
    end
  end
end
