require 'qa_spec_helper'

describe 'My Account page', js: true do

  let(:user) { create_user(email: 'email@plink.com', password: 'test123', first_name: 'tester', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image') }

  before(:each) do
    @virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    wallet = create_wallet(user_id: user.id)
  end

  subject { page }

  context 'as a non-linked user' do
    before(:each) do
      sign_in('email@plink.com', 'test123')
      click_on 'My Account'
    end

    it { should have_text "You haven't linked a card yet." }
    it { should have_link 'Link Card' }
    it { should have_image 'icon_alert_pink' }
    it 'should allow the user to link a card' do
      click_on 'Link Card'
      page.should have_css '#card-add-modal'
    end

    it 'should display the users information' do
      page.should have_text(user.first_name, count: 2)
      page.should have_text(user.first_name.upcase, count: 1)
      page.should have_text("You have 0 Plink Points.", count: 2)
    end

    it 'should allow a user to share via gigya' do
      page.should have_css('div', 'Facebook')
      page.should have_css('div', 'Twitter')
      click_on 'Refer a Friend'
      page.should have_css('iframe')
    end

    context 'as a user updating their display name' do
      before { page.all('a', text: 'Change')[0].click }

      it { should have_field('first_name') }
      it { should have_field('password') }

      it 'should not change if name contains numbers' do
        fill_in 'first_name', with: 'Name123'
        fill_in 'password',   with: 'test123'
        click_on 'Change Your Name'
        page.should have_text 'Please enter only alphabetical characters for your name.'
      end

      it 'should not change if name contains symbols' do
        fill_in 'first_name', with: 'Name*&%'
        fill_in 'password',   with: 'test123'
        click_on 'Change Your Name'
        page.should have_text 'Please enter only alphabetical characters for your name.'
      end

      it 'should not change if name contains spaces' do
        fill_in 'first_name', with: 'name name'
        fill_in 'password',   with: 'test123'
        click_on 'Change Your Name'
        page.should have_text 'Please enter only alphabetical characters for your name.'
      end

      pending 'correction' do
        it 'should not change if password is incorrect' do
          fill_in 'first_name', with: 'qa_spec_test@xample.com'
          fill_in 'password',   with: 'test44444444'
          click_on 'Change Your Name'
          page.should have_text 'Current password is incorrect'
        end
      end

      it 'should update the users email if all conditions are met' do
        fill_in 'first_name', with: 'Newname'
        fill_in 'password',   with: 'test123'
        click_on 'Change Your Name'
        page.should have_text 'Newname'
        page.should have_text 'Account updated successfully'
      end
    end


    context 'as a user updating their email address' do
      before { page.all('a', text: 'Change')[1].click }

      it { should have_field('email') }
      it { should have_field('password') }

      it 'should not change if email format is invalid' do
        fill_in 'email',    with: 'qa_spec_testxampleom'
        fill_in 'password', with: 'test123'
        click_on 'Change Your Email'
        page.should have_text 'Please enter a valid email address'
      end

      pending 'correction' do
        it 'should not change if password is incorrect' do
          fill_in 'email',    with: 'qa_spec_test@xample.com'
          fill_in 'password', with: 'test44444444'
          click_on 'Change Your Email'
          page.should have_text 'Current password is incorrect'
        end
      end

      it 'should not change if the requested change email is an existing user' do
        create_user(password:'password', email: 'existing@plink.com')
        fill_in 'email',    with: 'existing@plink.com'
        fill_in 'password', with: 'test123'
        click_on 'Change Your Email'
        page.should have_text "You've entered an email address that is already registered with Plink."
      end

      it 'should update the users email if all conditions are met' do
        fill_in 'email',    with: 'switch@plink.com'
        fill_in 'password', with: 'test123'
        click_on 'Change Your Email'
        page.should have_text 'switch@plink.com'
        page.should have_text 'Account updated successfully'
      end
    end


    context 'as a user updating their password' do
      before { page.all('a', text: 'Change')[2].click }

      it { should have_field('email') }
      it { should have_field('password') }

      it 'should error if password does not match confirmation' do
        fill_in 'new_password',              with: 'test123'
        fill_in 'new_password_confirmation', with: 'test12346'
        fill_in 'password',                  with: 'test123'
        click_on 'Change Your Password'
        page.should have_text "New password doesn't match confirmation"
      end

      pending 'correction' do
        it 'should error if the user enters the wrong password' do
          fill_in 'new_password',              with: 'test123'
          fill_in 'new_password_confirmation', with: 'test123'
          fill_in 'password',                  with: 'wrong'
          click_on 'Change Your Password'
          page.should have_text "Current password is incorrect"
        end
      end

      it 'should error if the user enters a short password' do
        fill_in 'new_password',              with: '1'
        fill_in 'new_password_confirmation', with: '1'
        fill_in 'password',                  with: 'test123'
        click_on 'Change Your Password'
        page.should have_text "New password must be at least 6 characters long"
      end

      it 'should change the users password if all fields are correct' do
        fill_in 'new_password',              with: 'newPass'
        fill_in 'new_password_confirmation', with: 'newPass'
        fill_in 'password',                  with: 'test123'
        click_on 'Change Your Password'
        page.should have_text "Account updated successfully"
      end
    end
  end


  context 'as a linked user' do
    before(:each) do
      create_oauth_token(user_id: user.id)
      users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: @virtual_currency.id)
      institution = create_institution(name: 'Bank of representin')
      users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
      create_users_institution_account(user_id: user.id, name: 'representing checks', users_institution_id: users_institution.id, account_number_last_four: 4321)


      sign_in('email@plink.com', 'test123')
      click_on 'My Account'
    end

    it { should have_text 'Active' }
    it { should have_image 'icon_active' }
    it { should }



    context 'who has recent activity' do
      before(:each) do
        #Add some points and activity
      end

    end
  end
end