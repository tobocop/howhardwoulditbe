require 'spec_helper'

describe 'Registering through a registration link' do
  let!(:registration_start_event_type) { create_event_type(name: Plink::EventTypeRecord.registration_start_type) }
  let!(:email_capture_event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }
  let!(:card_add_event_type) { create_event_type(name: Plink::EventTypeRecord.card_add_type) }

  let(:affiliate) { create_affiliate }
  let(:campaign) { create_campaign(campaign_hash: 'willbedeprecated') }
  let(:landing_page) { create_landing_page(partial_path: 'example') }

  let!(:registration_link) {
    create_registration_link(
      affiliate_id: affiliate.id,
      campaign_id: campaign.id,
      landing_page_records: [landing_page]
    )
  }

  before do
    create_virtual_currency
  end

  context 'with custom landing pages', js:true do
    it 'shows the user one of the landing pages', :vcr do
      visit registration_link_path(registration_link.id, 'subID' => 'one', 'subID2' => 'two', 'subID3' => 'three', 'subID4' => 'four')

      registration_start_event = Plink::EventRecord.order('eventID desc').first

      registration_start_event.event_type_id.should == registration_start_event_type.id
      registration_start_event.campaign_id.should == campaign.id
      registration_start_event.affiliate_id.should == affiliate.id
      registration_start_event.sub_id.should == 'one'
      registration_start_event.sub_id_two.should == 'two'
      registration_start_event.sub_id_three.should == 'three'
      registration_start_event.sub_id_four.should == 'four'
      registration_start_event.path_id.should == 1
      registration_start_event.landing_page_id.should == landing_page.id
      registration_start_event.is_active.should be_true

      page.should have_content 'An example custom landing page'

      first('.header-button').click_link('Join')

      within '.sign-in-modal' do
        page.find('img[alt="Register with Email"]').click

        fill_in 'First Name', with: 'Frud'
        fill_in 'Email', with: 'furd@example.com'
        fill_in 'Password', with: 'pass1word'
        fill_in 'Verify Password', with: 'pass1word'

        click_on 'Start Earning Rewards'
      end

      page.should have_content 'Welcome, Frud!'

      email_capture_event = Plink::EventRecord.order('eventID desc').first

      email_capture_event.event_type_id.should == email_capture_event_type.id
      email_capture_event.campaign_id.should == campaign.id
      email_capture_event.affiliate_id.should == affiliate.id
      email_capture_event.sub_id.should == 'one'
      email_capture_event.sub_id_two.should == 'two'
      email_capture_event.sub_id_three.should == 'three'
      email_capture_event.sub_id_four.should == 'four'
      email_capture_event.path_id.should == 1
      email_capture_event.landing_page_id.should == landing_page.id
      email_capture_event.is_active.should be_true

      registration_start_event.reload
      registration_start_event.user_id.should == email_capture_event.user_id
    end

    it 'shows a share page if there is one', :vcr do
      share_page = create_share_page(partial_path: 'example')
      registration_link.share_page_records << share_page

      visit registration_link_path(registration_link.id, 'subID' => 'one', 'subID2' => 'two', 'subID3' => 'three', 'subID4' => 'four')

      first('.header-button').click_link('Join')

      # Use email since auth via FB cannot be integration tested with capybara
      share_page = share_page_path(registration_link.share_page_records.first)
      ApplicationController.any_instance.stub(:get_return_to_path).and_return(share_page)
      within '.sign-in-modal' do
        page.find('img[alt="Register with Email"]').click

        fill_in 'First Name', with: 'Frud'
        fill_in 'Email', with: 'furd@example.com'
        fill_in 'Password', with: 'pass1word'
        fill_in 'Verify Password', with: 'pass1word'

        click_on 'Start Earning Rewards'
      end

      page.should have_link 'Take me to my wallet'
      page.should have_xpath "//a[@href='/wallet?link_card=true']"

      click_on 'I Want to Share'

      page.should have_css '[gigid="showShareUI"]'

      # This event is triggered via a successful user share on Gigya:
      page.execute_script('$(document).trigger("Plink.GigyaShareFlowWidget._onSendDone()");')

      page.should have_content 'Welcome, Frud!'
    end
  end

  context 'deprecated paths', js:true do
    before do
      create_registration_link_mapping(affiliate_id: affiliate.id, campaign_id: campaign.id, registration_link_id: registration_link.id)
    end

    it 'forwards to a new registration link', :vcr do
      visit deprecated_registration_link_path('aid' => affiliate.id, 'c' => 'willbedeprecated', 'subID' => 'one', 'subID2' => 'two', 'subID3' => 'three', 'subID4' => 'four')

      page.should have_content 'An example custom landing page'

      page.current_path.should == registration_link_path(registration_link)

      registration_start_event = Plink::EventRecord.order('eventID desc').first

      registration_start_event.event_type_id.should == registration_start_event_type.id
      registration_start_event.campaign_id.should == campaign.id
      registration_start_event.affiliate_id.should == affiliate.id
      registration_start_event.sub_id.should == 'one'
      registration_start_event.sub_id_two.should == 'two'
      registration_start_event.sub_id_three.should == 'three'
      registration_start_event.sub_id_four.should == 'four'
      registration_start_event.path_id.should == 1
      registration_start_event.landing_page_id.should == landing_page.id
      registration_start_event.is_active.should be_true

    end
  end
end
