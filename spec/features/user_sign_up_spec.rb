require 'spec_helper'

describe 'User signup workflow' do
  let!(:linked_promotion) do
    create_hero_promotion({
      display_order: 2,
      image_url_one: '/assets/hero-gallery/TacoBell_1.jpg',
      link_one: '/faq',
      show_linked_users: true,
      show_non_linked_users: true,
      title: 'You want this. Now.'
    })
  end

  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
    create_hero_promotion({
      display_order: 1,
      image_url_one: '/assets/hero-gallery/7eleven_1.jpg',
      link_one: '',
      show_linked_users: true,
      show_non_linked_users: false,
      title: 'You want this.'
    })
  end

  context 'organic registration' do
    it 'should create an account, email the user, and drop the user on the instituion search path', :vcr, js: true, driver: :selenium do
      visit '/'

      click_link 'Join'

      within '.modal' do
        page.find('img[alt="Register with Email"]').click

        fill_in 'First Name', with: ''
        fill_in 'Email', with: ''
        fill_in 'Password', with: ''
        fill_in 'Verify Password', with: ''

        click_on 'Start Earning Rewards'
      end

      within '.modal' do
        page.should have_content 'Please provide a First name'
        page.should have_content 'Email address is required'

        fill_in 'First Name', with: 'Joe'
        fill_in 'Email', with: 'test2@example.com'
        fill_in 'Password', with: 'test123'
        fill_in 'Verify Password', with: 'test123'

        click_on 'Start Earning Rewards'
      end

      within ".welcome-text" do
        page.should have_content('Welcome, Joe!')
      end

      current_path.should == institution_search_path

      visit wallet_path

      page.should_not have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
      page.should have_css('img[src="/assets/hero-gallery/TacoBell_1.jpg"]')

      find('.hero-promotion-link').click

      within_window page.driver.browser.window_handles.last do
        page.current_path.should == '/faq'
      end

      email = ActionMailer::Base.deliveries.last
      email.subject.should == 'Get Double Plink Points Through May 31, 2014'

      click_on 'Wallet'

      page.should have_content 'MY WALLET'
      page.should have_content 'This slot is empty.', count: 3
      page.should have_content 'This slot is locked.', count: 2

      click = Plink::HeroPromotionClickRecord.all
      click.count.should == 1
      click.first.hero_promotion_id.should == linked_promotion.id
      click.first.user_id.should == Plink::UserRecord.last.id
    end
  end

  pending 'social registration' do
    after(:each) do
      delete_users_from_gigya
    end

    context 'with facebook' do
      it 'allows a user to register with their facebook account', js: true, flaky: true do
        visit '/'

        click_on 'Join'

        within '.modal' do
          page.should have_content 'Join Plink'
        end

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

        current_path.should == wallet_path

        click_on 'Wallet'

        page.should have_content 'MY WALLET'
        page.should have_content 'This slot is empty.', count: 3
        page.should have_content 'This slot is locked.', count: 2
      end
    end

    context 'with twitter' do
      it 'allows a user to register with their twitter account', js: true, flaky: true do
        visit '/'

        click_on 'Join'

        page.should have_content 'Join Plink'

        within '.modal' do
          page.find('[gigid="twitter"]').click
        end

        within_window page.driver.browser.window_handles.last do

          page.should have_content 'Username or email'

          fill_in 'Username or email', with: 'mattplink'
          fill_in 'Password', with: 'test123'

          click_button 'Authorize app'
        end

        page.should have_content 'Email'

        fill_in 'profile.email', with: 'matt@example.com'
        click_button 'Submit'

        page.should have_content('Welcome, Matt!')

        current_path.should == wallet_path

        click_on 'Wallet'

        page.should have_content 'MY WALLET'
        page.should have_content 'This slot is empty.', count: 3
        page.should have_content 'This slot is locked.', count: 2
      end
    end
  end

  context 'referral' do
    it 'lands the user on the homepage after being referred', :vcr do
      referrer = create_user
      visit "/refer/#{referrer.id}/aid/1264"

      current_path.should == root_path
    end
  end

  context 'form error messages', js: true do
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

    it 'tells the user the email is not valid' do
      sign_up_user('Matt', 'notarealemail', 'test123', 'test123')
      page.should have_text('Please enter a valid email address')
      page.should have_link("Having trouble? Contact Us")
    end

    context 'when the user already exists' do
      before(:each) do
        user = create_user( email: 'test@plink.com', password: 'test123', first_name: 'Matt')
        wallet = create_wallet(user_id: user.id)
     end

      it 'tells the user that the email is already registered', :vcr do
        sign_up_user('Matt', 'test@plink.com', 'test123', 'test123')
        page.should have_text("You've entered an email address that is already registered with Plink.")
        page.should have_link("Having trouble? Contact Us")
      end
    end

  end
end
