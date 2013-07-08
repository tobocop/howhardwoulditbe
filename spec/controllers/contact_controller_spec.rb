require 'spec_helper'

describe ContactController do

  describe 'GET new' do
    it 'should assign @contact_form' do

      get :new

      assigns(:contact_form).should be_present

    end
  end

  describe 'POST create' do

    it 'should send an email to the default email address' do

      email_spy = mock('email')
      email_spy.should_receive(:deliver)

      ContactMailer.should_receive(:contact_email).with(
          from: 'bob@example.com',
          category: 'sorcery',
          message_text: 'i like to magic',
          first_name: 'Merlin',
          last_name: 'Haggard'
      ).and_return(email_spy)

      post :create, contact_form: {email: 'bob@example.com', first_name: 'Merlin', last_name: 'Haggard', message_text: 'i like to magic', category: 'sorcery'}

      page.should redirect_to thank_you_contact_path
    end
  end

end
