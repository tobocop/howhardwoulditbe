require 'spec_helper'

describe AfterUserRegistration do

  describe '#send_complete_your_registration_email' do
    let!(:non_linked_user) { create_user(email: 'nonlinked@plink.com', first_name: 'bobby') }
    let!(:linked_user) { create_user(email: 'linked@plink.com') }

    before do
      create_oauth_token(user_id: linked_user.id)
      create_users_institution_account(user_id: linked_user.id)
    end

    it 'sends if the user has not yet linked a card' do
      UserRegistrationMailer.should_receive(:complete_registration).with(first_name: 'bobby', email: 'nonlinked@plink.com').and_call_original

      AfterUserRegistration.send_complete_your_registration_email(non_linked_user.id)

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.to.should == [non_linked_user.email]
    end

    it 'does not send if the user has linked a card' do
      UserRegistrationMailer.should_not_receive(:complete_registration)

      AfterUserRegistration.send_complete_your_registration_email(linked_user.id)

      ActionMailer::Base.deliveries.should be_empty
    end
  end
end
