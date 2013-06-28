require 'qa_spec_helper'

describe 'Social add icons', js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    delete_users_from_gigya

    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies 
  end


#   it 'should link a valid FB account' do
#     fb_icon = find(:css, "div[alt=\"Facebook\"] > div > div").click
  
#     within_window page.driver.browser.window_handles.last do
#       fill_in 'Email', with: "matt.hamrick@plink.com"
#       fill_in 'Password:', with: 'test123'
#       click_button 'Log In'
#       page.execute_script "window.close();"
#     end
  
#     src = "http://cdn.gigya.com/gs/i/HTMLLogin/facebook_30_connected.png"
#     page.should have_xpath("//img[@src=\"#{src}\"]")
#   end


#   it 'should link a valid Twitter account' do
#     find(:css, "div[alt=\"Twitter\"] > div > div").click
  
#     within_window page.driver.browser.window_handles.last do
#       fill_in_twitter_handle
#       fill_in 'Password', with: 'test123'
#       click_button 'Authorize app'
#       page.execute_script "window.close();"
#     end

#     # if app asks for an email address, enter it
#     # if page.find('name', text: 'profile.email').set("matt@matt.com")
#       # fill in email
#     # end

#     src = "http://cdn.gigya.com/gs/i/HTMLLogin/twitter_30_connected.png"
#     page.should have_xpath("//img[@src=\"#{src}\"]")
#   end


#   it 'should reject an invalid facebook account' do
#     fb_icon = find(:css, "div[alt=\"Facebook\"] > div > div").click
  
#     within_window page.driver.browser.window_handles.last do
#       fill_in 'Email', with: "invalidaddress@plink.com"
#       fill_in 'Password:', with: 'invalidpw'
#       click_button 'Log In'
#       page.should have_text('Incorrect Email')
#     end
#   end

#   it 'should reject an invalid twitter account' do
#     fb_icon = find(:css, "div[alt=\"Twitter\"] > div > div").click
  
#     within_window page.driver.browser.window_handles.last do
#       fill_in_twitter_handle
#       fill_in 'Password', with: 'test123456'
#       click_button 'Authorize app'
#       page.should have_text('Invalid')
#     end
#   end
# end

describe "Invite Friends Link", js: true do
  before(:each) do
    delete_users_from_gigya
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
  end

  subject { page }

  it { should have_link ('Invite Friends') }


  it 'should have the correct referral link' do
    user = User.find_by_email('qa_spec_test@example.com')
    expectedURL = "http://plink.test:58891/refer/#{user.userID}/aid/1264"

    find_link('Invite Friends')[:href].should == expectedURL
  end


  it 'should share to facebook' do
  end


  it 'should share to twitter' do
    custom_message = "Custom Share Text#{Time.new}"   

    connect_twitter_account
    click_on 'Invite Friends'

    within '[gigid="showShareUI"]' do
      page.find('textarea').set(custom_message)
      page.all('td', text: 'Publish').last.click
    end
    visit 'https://www.twitter.com'
    page.should have_text(custom_message)
  end
end

def connect_twitter_account
  find(:css, "div[alt=\"Twitter\"] > div > div").click
  within_window page.driver.browser.window_handles.last do
    fill_in_twitter_handle
    fill_in 'Password', with: 'test123'
    click_button 'Authorize app'
    page.execute_script "window.close();"
  end
end

def fill_in_twitter_handle
  #if page.find Username
    fill_in 'Username', with: "mattplink"
  #end
end












