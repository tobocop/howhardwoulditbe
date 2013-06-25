require 'qa_spec_helper'

describe 'Social add icons', js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    delete_users_from_gigya
  end

  it 'should link a valid FB account' do
    fb_icon = find(:css, "div[alt=\"Facebook\"] > div > div").click

    within_window page.driver.browser.window_handles.last do
      fill_in 'Email', with: "matt.hamrick@plink.com"
      fill_in 'Password:', with: 'test123'
      click_button 'Log In'
      page.execute_script "window.close();"
    end

    src = "http://cdn.gigya.com/gs/i/HTMLLogin/facebook_30_connected.png"
    page.should have_xpath("//img[@src=\"#{src}\"]")
  end


  it 'should link a valid Twitter account' do
    fb_icon = find(:css, "div[alt=\"Twitter\"] > div > div").click

    within_window page.driver.browser.window_handles.last do
      fill_in 'Username', with: "mattplink"
      fill_in 'Password', with: 'test123'
      click_button 'Authorize app'
      page.execute_script "window.close();"
    end

    src = "http://cdn.gigya.com/gs/i/HTMLLogin/twitter_30_connected.png"
    page.should have_xpath("//img[@src=\"#{src}\"]")
  end


  # it 'should reject an invalid facebook account' do
  #   fb_icon = find(:css, "div[alt=\"Facebook\"] > div > div").click

  #   within_window page.driver.browser.window_handles.last do
  #     fill_in 'Email', with: "invalidaddress@plink.com"
  #     fill_in 'Password:', with: 'invalidpw'
  #     click_button 'Log In'
  #     page.should have_text('Incorrect Email')
  #   end
  # end

  # it 'should reject an invalid twitter account' do
  #   fb_icon = find(:css, "div[alt=\"Twitter\"] > div > div").click

  #   within_window page.driver.browser.window_handles.last do
  #     fill_in 'Username', with: "mattplink"
  #     fill_in 'Password', with: 'test123456'
  #     click_button 'Authorize app'
  #     page.should have_text('Invalid')
  #   end
  # end
end

