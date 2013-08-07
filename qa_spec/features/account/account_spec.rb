require 'qa_spec_helper'

describe 'My Account page', js: true do
  before(:each) do
    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")

    # Figure this out
    # user = Plink::UserService.where(emailAddress: "email@Plink.com")
    click_on 'My Account'
  end

  subject { page }

  it 'should display the users information' do
    page.should have_text('tester', count: 2)                      #change to user.name.downcase
    page.should have_text('TESTER', count: 1)                      #remove once the above is implemented
    page.should have_text('email@Plink.com')
    page.should have_image "silhouette"
    page.should have_text("You have 0 Plink Points.", count: 2)    #Swap out for user.balance
  end

  it 'should allow a user to share via gigya' do
    page.should have_css('div', 'Facebook')
    page.should have_css('div', 'Twitter')
    click_on 'Refer a Friend'
    page.should have_css('iframe')                                 #Likely needs a better selector
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


  context 'as a non-linked user' do
    it { should have_text "You haven't linked a card yet." }
    it { should have_link 'Link Card' }
    it { should have_image 'icon_alert_pink' }
    it 'should allow the user to link a card' do
      click_on 'Link Card'
      page.should have_css '#card-add-modal'
    end
  end


  context 'as a linked user' do

    context 'as a user who has recent activity' do
    end
  end
end