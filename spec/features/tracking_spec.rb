require 'spec_helper'

describe 'event tracking' do

  before do
    create_virtual_currency
    @event_type = create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    @campaign = create_campaign(campaign_hash: 'MYTESTHASH')
  end

  it 'tracks events', js: true do
    visit '/tracking/new?aid=1324&subid=one&subID2=two&subid3=three&SuBid4=four&c=MYTESTHASH&pathID=298'

    page.current_path.should == '/'

    click_on 'Join'


    within '.sign-in-modal' do
      fill_in 'First Name', with: 'Frud'
      fill_in 'Email', with: 'furd@example.com'
      fill_in 'Password', with: 'pass1word'
      fill_in 'Verify Password', with: 'pass1word'

      click_on 'Start Earning Rewards'
    end

    page.should have_content 'Welcome, Frud!'

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

  it 'tracks events for a social registration and not on login', js: true do
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

    page.should have_content('Welcome, Matt!')

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

    click_on 'Log Out'

    click_on 'Join'

    page.should have_content 'Join Plink'

    within '.modal' do
      page.find('[gigid="facebook"]').click
    end

    page.should have_content('Welcome, Matt!')

    tracked_event_new = Plink::EventRecord.order('eventID desc').first

    tracked_event_new.id.should == tracked_event.id

  end

end