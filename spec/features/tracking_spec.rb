require 'spec_helper'

describe 'event tracking' do
  let!(:affiliate) { create_affiliate(email_add_pixel: 'myherp_myherp_mylovelyladyderp') }

  before do
    create_virtual_currency
    @event_type = create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
    @campaign = create_campaign(campaign_hash: 'MYTESTHASH')
  end

  it 'tracks events', :vcr, js: true, driver: :selenium do
    visit "/tracking/new?aid=#{affiliate.id}&subid=one&subID2=two&subid3=three&SuBid4=four&c=MYTESTHASH&pathID=298"

    page.current_path.should == '/'

    click_on 'Join'

    within '.sign-in-modal' do
      page.find('img[alt="Register with Email"]').click

      fill_in 'First Name', with: 'Frud'
      fill_in 'Email', with: 'furd@example.com'
      fill_in 'Password', with: 'pass1word'
      fill_in 'Verify Password', with: 'pass1word'

      click_on 'Start Earning Rewards'
    end

    within ".welcome-text" do
      page.should have_content 'Welcome, Frud!'
    end

    page.should have_content 'myherp_myherp_mylovelyladyderp'

    tracked_event = Plink::EventRecord.order('eventID desc').first

    tracked_event.campaign_id.should == @campaign.id
    tracked_event.event_type_id.should == @event_type.id
    tracked_event.affiliate_id.should == affiliate.id
    tracked_event.sub_id.should == 'one'
    tracked_event.sub_id_two.should == 'two'
    tracked_event.sub_id_three.should == 'three'
    tracked_event.sub_id_four.should == 'four'
    tracked_event.path_id.should == 298
    tracked_event.is_active.should be_true
    tracked_event.created_at.should be
  end

  pending 'tracks events for a social registration and not on login', :vcr, js: true, driver: :selenium, skip_in_build: true do
    page.driver.browser.manage.delete_all_cookies

    visit '/tracking/new?aid=1324&subid=one&subID2=two&subid3=three&SuBid4=four&c=MYTESTHASH&pathID=298'

    page.current_path.should == '/'

    click_on 'Join'

    page.should have_content 'Join Plink'

    within '.modal' do
      page.find('[gigid="facebook"]').click
    end

    within_window page.driver.browser.window_handles.last do
      page.should have_content 'Password'
      fill_in 'Email', with: 'matt.hamrick@plink.com'
      fill_in 'Password:', with: 'test123'
      click_button 'Log In'
    end

    within ".welcome-text" do
      page.should have_content('Welcome, Matt!')
    end

    tracked_event = Plink::EventRecord.order('eventID desc').first

    tracked_event.campaign_id.should == @campaign.id
    tracked_event.event_type_id.should == @event_type.id
    tracked_event.affiliate_id.should == 1324
    tracked_event.sub_id.should == 'one'
    tracked_event.sub_id_two.should == 'two'
    tracked_event.sub_id_three.should == 'three'
    tracked_event.sub_id_four.should == 'four'
    tracked_event.path_id.should == 298
    tracked_event.is_active.should be_true
    tracked_event.created_at.should be

  end
end
