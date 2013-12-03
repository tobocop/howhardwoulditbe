require 'spec_helper'

describe UserReverificationEmailPresenter do
  let(:institution) { create_institution(name: 'Bank of AMERRRICA!', home_url: 'http://chase.com') }
  let(:user_record) { create_user }
  let(:user) { Plink::UserService.new.find_by_id(user_record.id) }
  let(:users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }
  let(:intuit_account) { Plink::IntuitAccountService.new.find_by_user_id(user_record.id) }
  let(:user_reverification_record) {
    create_user_reverification(
      completed_on: nil,
      is_notification_successful: false,
      intuit_error_id: 103,
      user_id: user.id,
      users_institution_id: users_institution.id
    )
  }

  subject(:user_reverification_email_presenter) {
    UserReverificationEmailPresenter.new(user_reverification_record, user, intuit_account)
  }

  before do
    create_oauth_token(user_id: user.id)
    create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id)
  end

  describe 'initialize' do
    it 'initializes with a user_reverification_record, a user, and an intuit_account' do
      user_reverification_email_presenter.created.should == user_reverification_record.created
      user_reverification_email_presenter.id.should == user_reverification_record.id
      user_reverification_email_presenter.intuit_account.should == intuit_account
      user_reverification_email_presenter.intuit_error_id.should == 103
      user_reverification_email_presenter.link.should be_nil
      user_reverification_email_presenter.notice_type.should == 'initial'
      user_reverification_email_presenter.user_reverification_record.should == user_reverification_record
    end
  end

  describe '#can_be_sent?' do
    let(:user) { double(id: 2, can_receive_plink_email?: true) }
    let(:intuit_account) { double(active?: false) }
    let(:user_reverification_email_presenter) {
      UserReverificationEmailPresenter.new(double, user, intuit_account)
    }

    it 'returns true if the user can receive plink emails and the intuit account is not active' do
      user_reverification_email_presenter.can_be_sent?.should be_true
    end

    it 'returns false if the user cannot receive plink emails' do
      user.stub(can_receive_plink_email?: false)
      user_reverification_email_presenter.can_be_sent?.should be_false
    end

    it 'returns false if the intuit account is active' do
      intuit_account.stub(active?: true)
      user_reverification_email_presenter.can_be_sent?.should be_false
    end
  end

  describe '#removal_date' do
    it 'returns the day 2 weeks from when the reverification was created' do
      user_reverification_email_presenter.removal_date.should == 2.weeks.from_now.to_date
    end
  end

  context 'email messaging' do
    before do
      user_reverification_record.stub(:notice_type).and_return('awesome_notice')
      user_reverification_record.stub(:intuit_error_id).and_return(1028)
    end

    describe '.explanation_message' do
      it 'calls the proper tranlsation key' do
        I18n.should_receive(:t).
          with('application.intuit_error_messages.emails.awesome_notice.error_1028.explanation_message').
          and_return('my custom message')
        user_reverification_email_presenter.explanation_message.should == 'my custom message'
      end
    end

    describe '.html_link_message' do
      it 'calls the proper tranlsation key with the bank name and the reverification link' do
        user_reverification_record.stub(:link).and_return('http://chasey.com')
        I18n.should_receive(:t).
          with(
            'application.intuit_error_messages.emails.awesome_notice.error_1028.html_link_message',
            institution_name: 'Bank of AMERRRICA!',
            reverification_link: 'http://chasey.com'
          ).and_return('my custom message')
        user_reverification_email_presenter.html_link_message.should == 'my custom message'
      end

      it 'uses an account url if the reverification record link is nil' do
        user_reverification_record.stub(:link).and_return(nil)
        user_reverification_email_presenter.stub(user_token: 'my_token')

        I18n.should_receive(:t).
          with(
            'application.intuit_error_messages.emails.awesome_notice.error_1028.html_link_message',
            institution_name: 'Bank of AMERRRICA!',
            reverification_link: 'http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token'
          ).and_return('my custom message')
        user_reverification_email_presenter.html_link_message.should == 'my custom message'
      end
    end

    describe '.text_link_message' do
      it 'calls the proper tranlsation key with the bank name and the reverification link' do
        user_reverification_record.stub(:link).and_return('http://chasey.com')
        I18n.should_receive(:t).
          with(
            'application.intuit_error_messages.emails.awesome_notice.error_1028.text_link_message',
            institution_name: 'Bank of AMERRRICA!',
            reverification_link: 'http://chasey.com'
          ).and_return('my custom message')
        user_reverification_email_presenter.text_link_message.should == 'my custom message'
      end

      it 'uses an account url if the reverification record link is nil' do
        user_reverification_record.stub(:link).and_return(nil)
        user_reverification_email_presenter.stub(user_token: 'my_token')

        I18n.should_receive(:t).
          with(
            'application.intuit_error_messages.emails.awesome_notice.error_1028.text_link_message',
            institution_name: 'Bank of AMERRRICA!',
            reverification_link: 'http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token'
          ).and_return('my custom message')
        user_reverification_email_presenter.text_link_message.should == 'my custom message'
      end
    end
  end
end
