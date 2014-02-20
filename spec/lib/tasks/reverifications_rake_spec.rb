require 'spec_helper'

describe 'reverifications:insert_reverification_notices' do
  include_context 'rake'

  let!(:plink_points) { create_virtual_currency(subdomain: 'www') }
  let!(:user) { create_user(email: 'myshitisbroken@intuit.com') }
  let!(:institution) { create_institution }
  let!(:old_users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }
  let!(:users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }

  before do
    create_oauth_token(user_id: user.id)
    create_users_institution_account(user_id: user.id, users_institution_id: old_users_institution.id)
    create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id)
  end

  it 'gets all errors that require immediate action' do
    Plink::UserIntuitErrorRecord.should_receive(:errors_that_require_attention).
      and_return([])

    capture_stdout { subject.invoke }
  end

  context 'errors that require immediate action' do
    let!(:user_intuit_error) {
      create_user_intuit_error(
        intuit_error_id: 103,
        user_id: user.id,
        users_institution_id: users_institution.id
      )
    }

    it 'immediately queues a reverification notice for error code 103' do
      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 103,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      capture_stdout { subject.invoke }
    end

    it 'immediately queues a reverification notice for error code 106' do
      user_intuit_error.update_attribute('intuit_error_id', 106)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 106,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      capture_stdout { subject.invoke }
    end

    it 'immediately queues a reverification notice for error code 108' do
      user_intuit_error.update_attribute('intuit_error_id', 108)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 108,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      capture_stdout { subject.invoke }
    end

    it 'immediately queues a reverification notice for error code 109' do
      user_intuit_error.update_attribute('intuit_error_id', 109)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 109,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      capture_stdout { subject.invoke }
    end

    it 'does not queue a reverification notice if the users active institution does not match that of the error' do
      user_intuit_error.update_attribute('users_institution_id', old_users_institution.id)

      Plink::UserReverificationRecord.should_not_receive(:create)

      capture_stdout { subject.invoke }
    end

    it 'does not queue duplicate reverification notices' do
      user_intuit_error = create_user_intuit_error(
        intuit_error_id: 103,
        user_id: user.id,
        users_institution_id: users_institution.id
      )

      capture_stdout { subject.invoke }

      Plink::UserReverificationRecord.all.length.should == 1
    end

    it 'does not queue reverification notices to force deactivated members' do
      user.update_attribute('isForceDeactivated', true)

      Plink::UserReverificationRecord.should_not_receive(:create)
      capture_stdout { subject.invoke }
    end

    it 'does not queue reverification notices to white label members' do
      swagbucks = create_virtual_currency(subdomain: 'swagbucks')
      user.primary_virtual_currency = swagbucks
      user.save

      Plink::UserReverificationRecord.should_not_receive(:create)
      capture_stdout { subject.invoke }
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Plink::UserReverificationRecord.stub(:create).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/insert_reverification_notices/)

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      Plink::UserReverificationRecord.stub(:create).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/user\.id = \d+/)

      subject.invoke
    end

    it 'includes the user_intuit_error.id in the record-level exception text' do
      Plink::UserReverificationRecord.stub(:create).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/user_intuit_error\.id = \d+/)

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::UserIntuitErrorRecord.stub(:errors_that_require_attention).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/insert_reverification_notices/)

      subject.invoke
    end

    it 'does not include user.id in the task-level exception text' do
      Plink::UserIntuitErrorRecord.stub(:errors_that_require_attention).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id =/)

      subject.invoke
    end

    it 'does not include user_intuit_error.id in the task-level exception text' do
      Plink::UserIntuitErrorRecord.stub(:errors_that_require_attention).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user_intuit_error\.id =/)

      subject.invoke
    end
  end

  context 'errors for multiple days' do
    let(:valid_params) {
      {
        intuit_error_id: intuit_error_id,
        user_id: user.id,
        users_institution_id: users_institution.id
      }
    }

    before do
      past_days = 2..5
      past_days.each { |past_day| create_user_intuit_error(valid_params.merge(created: past_day.days.ago)) }
    end

    context 'error code 185' do
      let(:intuit_error_id) { 185 }

      it 'queues a notice if the user has received error code 185 for 6 days in a row' do
        most_recent_error = create_user_intuit_error(valid_params.merge(created: 1.day.ago))
        create_user_intuit_error(valid_params.merge(created: 6.days.ago))

        Plink::UserReverificationRecord.should_receive(:create).
          with({
            intuit_error_id: 185,
            user_id: user.id,
            users_institution_id: users_institution.id,
            users_intuit_error_id: most_recent_error.id
          })

        capture_stdout { subject.invoke }
      end

      it 'queues a notice if the user has received error code 185 for 5 days in a row' do
        user_intuit_error = create_user_intuit_error(valid_params)
        user_intuit_error.created = 5.days.ago
        user_intuit_error.save

        Plink::UserReverificationRecord.should_receive(:create).
          with({
            intuit_error_id: 185,
            user_id: user.id,
            users_institution_id: users_institution.id,
            users_intuit_error_id: user_intuit_error.id
          })

        capture_stdout { subject.invoke }
      end

      it 'does not queue a notice if the user has received error code 185 for 4 days in a row' do
        Plink::UserReverificationRecord.should_not_receive(:create)
        capture_stdout { subject.invoke }
      end
    end

    context 'error code 187' do
      let(:intuit_error_id) { 187 }

      it 'queues a notice if the user has received error code 187 for 6 days in a row' do
        most_recent_error = create_user_intuit_error(valid_params.merge(created: 1.day.ago))
        create_user_intuit_error(valid_params.merge(created: 6.days.ago))

        Plink::UserReverificationRecord.should_receive(:create).
          with({
            intuit_error_id: 187,
            user_id: user.id,
            users_institution_id: users_institution.id,
            users_intuit_error_id: most_recent_error.id
          })

        capture_stdout { subject.invoke }
      end

      it 'queues a notice if the user has received error code 187 for 5 days in a row' do
        user_intuit_error = create_user_intuit_error(valid_params)
        user_intuit_error.created = 5.days.ago
        user_intuit_error.save

        Plink::UserReverificationRecord.should_receive(:create).
          with({
            intuit_error_id: 187,
            user_id: user.id,
            users_institution_id: users_institution.id,
            users_intuit_error_id: user_intuit_error.id
          })

        capture_stdout { subject.invoke }
      end

      it 'does not queue a notice if the user has received error code 187 for 4 days in a row' do
        Plink::UserReverificationRecord.should_not_receive(:create)
        capture_stdout { subject.invoke }
      end
    end
  end
end

describe 'reverifications:send_reverification_notices' do
  include_context 'rake'

  let!(:plink_points) { create_virtual_currency(subdomain: 'www') }
  let!(:institution) { create_institution(name: 'Bank of AMERRRICA!', home_url: 'http://chase.com') }
  let!(:user) { create_user(first_name: 'bobby', email: 'myshitisbroken@intuit.com', is_subscribed: true) }
  let!(:old_users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }
  let!(:users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }
  let!(:user_reverification) {
    create_user_reverification(
      completed_on: nil,
      is_notification_successful: false,
      intuit_error_id: 103,
      user_id: user.id,
      users_institution_id: users_institution.id
    )
  }
  let(:mailer) { double(notice_email: true) }

  before do
    create_oauth_token(user_id: user.id)
    create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id)
    ReverificationMailer.stub(delay: mailer)
    AutoLoginService.stub(generate_token: 'my_token')
  end

  context 'un-notified reverifications' do
    it 'emails users who have an unsent notification' do
      mailer.should_receive(:notice_email).
        with({
        additional_category_information: 103,
        email: 'myshitisbroken@intuit.com',
        explanation_message: "We're unable to access your Plink account's transaction history - it looks like the username or password for your online bank account has changed.",
        first_name: 'bobby',
        html_link_message: "Please <a href='http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token'>update your Plink account</a> with your current Bank of AMERRRICA! login info.",
        removal_date: 2.weeks.from_now.to_date,
        text_link_message: "Please update your Plink account with your current Bank of AMERRRICA! login info by clicking here: http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token."
      })

      capture_stdout { subject.invoke }
    end

    it 'updates the reverification flagging it as notified' do
      mailer.stub(:notice_email)

      capture_stdout { subject.invoke }

      user_reverification.reload.is_notification_successful.should be_true
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Plink::IntuitAccountService.any_instance.stub(:find_by_user_id).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/send_reverification_notices/)

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      Plink::IntuitAccountService.any_instance.stub(:find_by_user_id).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/user\.id = \d+/)

      subject.invoke
    end

    it 'includes the reverification_record.id in the record-level exception text' do
      Plink::IntuitAccountService.any_instance.stub(:find_by_user_id).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/reverification_record\.id = \d+/)

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::UserReverificationRecord.stub(:requiring_notice).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_receive(:handle).with(/send_reverification_notices/)

      subject.invoke
    end

    it 'does not include user.id in the task-level exception text' do
      Plink::UserReverificationRecord.stub(:requiring_notice).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id = \d+/)

      subject.invoke
    end

    it 'does not include reverification_record.id in the task-level exception text' do
      Plink::UserReverificationRecord.stub(:requiring_notice).and_raise(ActiveRecord::ConnectionNotEstablished)

      ::Exceptional::Catcher.should_not_receive(:handle).with(/reverification_record\.id = \d+/)

      subject.invoke
    end
  end

  context 'reverifications created 3 days ago' do
    before do
      user_reverification.update_attribute('created', 3.days.ago)
      user_reverification.update_attribute('isNotificationSuccessful', true)
    end

    it 'emails users who have a reverification record from three days ago' do
      mailer.should_receive(:notice_email).
        with({
        additional_category_information: 103,
        email: 'myshitisbroken@intuit.com',
        explanation_message: "Just a reminder: we're unable to access your Plink account's transaction history - it looks like the username or password for your online bank account has changed.",
        first_name: 'bobby',
        html_link_message: "Please <a href='http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token'>update your Plink account</a> with your current Bank of AMERRRICA! login info.",
        removal_date: (2.weeks.from_now - 3.days).to_date,
        text_link_message: "Please update your Plink account with your current Bank of AMERRRICA! login info by clicking here: http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token."
      })

      capture_stdout { subject.invoke }
    end
  end

  context 'reverifications created 7 days ago' do
    before do
      user_reverification.update_attribute('created', 7.days.ago)
      user_reverification.update_attribute('isNotificationSuccessful', true)
    end

    it 'emails users who have a reverification record from seven days ago' do
      mailer.should_receive(:notice_email).
        with({
        additional_category_information: 103,
        email: 'myshitisbroken@intuit.com',
        explanation_message: "Just a reminder: we're unable to access your Plink account's transaction history - it looks like the username or password for your online bank account has changed.",
        first_name: 'bobby',
        html_link_message: "Please <a href='http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token'>update your Plink account</a> with your current Bank of AMERRRICA! login info.",
        removal_date: (2.weeks.from_now - 7.days).to_date,
        text_link_message: "Please update your Plink account with your current Bank of AMERRRICA! login info by clicking here: http://plink.test:58891/account/login_from_email?link_card=true&user_token=my_token."
      })

      capture_stdout { subject.invoke }
    end
  end

  it 'does not email users who have already completed their reverification' do
    user_reverification.update_attribute('completed_on', Time.zone.now)
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end

  it 'does not email users who have already been notified their account needs to be reverified' do
    user_reverification.update_attribute('is_notification_successful', true)
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end

  it 'does not email users who have a different active institution then what is on the reverification' do
    user_reverification.update_attribute('users_institution_id', old_users_institution.id)
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end

  it 'does not email force deactivated users' do
    user.update_attribute('isForceDeactivated', true)
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end

  it 'does not email white label users' do
    swagbucks = create_virtual_currency(subdomain: 'swagbucks')
    user.primary_virtual_currency = swagbucks
    user.save
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end

  it 'does not email unsubscribed users' do
    user.update_attribute('isSubscribed', false)
    mailer.should_not_receive(:notice_email)
    capture_stdout { subject.invoke }
  end
end

describe 'reverifications:remove_accounts_with_expired_reverifications' do
  include_context 'rake'

  let!(:user) { create_user(first_name: 'bobby', email: 'myshitisbroken@intuit.com', is_subscribed: true) }
  let!(:old_users_institution) { create_users_institution(user_id: user.id, institution_id: 2) }
  let!(:users_institution) { create_users_institution(user_id: user.id, institution_id: 2) }
  let!(:users_institution_account) {
    create_users_institution_account(
      account_id: 298,
      user_id: user.id,
      users_institution_id: users_institution.id,
      in_intuit: true
    )
  }
  let!(:users_institution_account_staging) {
    create_users_institution_account_staging(
      account_id: 28,
      user_id: user.id,
      users_institution_id: users_institution.id,
      in_intuit: true
    )
  }
  let!(:user_reverification) {
    create_user_reverification(
      completed_on: nil,
      is_notification_successful: false,
      intuit_error_id: 103,
      user_id: user.id,
      users_institution_id: users_institution.id
    )
  }

  let(:intuit_account_removal_service) { double(:remove) }

  before do
    user_reverification.update_attribute('created', 2.weeks.ago)
    Intuit::AccountRemovalService.stub(delay: intuit_account_removal_service)
  end

  it 'removes all accounts associated to a reverification that has not been completed in 2 weeks' do
    intuit_account_removal_service.should_receive(:remove).with(298, user.id, users_institution.id)
    intuit_account_removal_service.should_receive(:remove).with(28, user.id, users_institution.id)

    capture_stdout { subject.invoke }
  end

  it 'removes accounts even if they are no longer the active account' do
    user_reverification.update_attribute('users_institution_id', old_users_institution.id)
    users_institution_account.update_attribute('users_institution_id', old_users_institution.id)
    users_institution_account_staging.update_attribute('users_institution_id', old_users_institution.id)

    intuit_account_removal_service.should_receive(:remove).with(298, user.id, old_users_institution.id)
    intuit_account_removal_service.should_receive(:remove).with(28, user.id, old_users_institution.id)

    capture_stdout { subject.invoke }
  end

  it 'removes the account if the reverification has been outstanding for more than 2 weeks' do
    user_reverification.update_attribute('created', 15.days.ago)
    intuit_account_removal_service.should_receive(:remove).with(298, user.id, users_institution.id)
    intuit_account_removal_service.should_receive(:remove).with(28, user.id, users_institution.id)

    capture_stdout { subject.invoke }
  end

  it 'delays the removals into a named queue' do
    Intuit::AccountRemovalService.should_receive(:delay).
      with(queue: 'intuit_account_removals').
      exactly(2).times.
      and_return(intuit_account_removal_service)

    intuit_account_removal_service.should_receive(:remove).with(298, user.id, users_institution.id)
    intuit_account_removal_service.should_receive(:remove).with(28, user.id, users_institution.id)

    capture_stdout { subject.invoke }
  end

  it 'does not remove the account if the reverification has been completed' do
    user_reverification.update_attribute('completed_on', 1.day.ago)
    intuit_account_removal_service.should_not_receive(:remove)

    capture_stdout { subject.invoke }
  end

  it 'does not remove the account if the reverification has been outstanding for less than 2 weeks' do
    user_reverification.update_attribute('created', 13.days.ago)
    intuit_account_removal_service.should_not_receive(:remove)

    capture_stdout { subject.invoke }
  end

  it 'logs record-level exceptions to Exceptional with the Rake task name' do
    Intuit::AccountRemovalService.stub(:delay).and_raise(Exception)

    ::Exceptional::Catcher.should_receive(:handle).with(/remove_accounts_with_expired_reverifications/)

    subject.invoke
  end

  it 'includes the user.id in the record-level exception text' do
    Intuit::AccountRemovalService.stub(:delay).and_raise(Exception)

    ::Exceptional::Catcher.should_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end

  it 'includes the user_reverification_record.id in the record-level exception text' do
    Intuit::AccountRemovalService.stub(:delay).and_raise(Exception)

    ::Exceptional::Catcher.should_receive(:handle).with(/user_reverification_record\.id = \d+/)

    subject.invoke
  end

  it 'logs Rake task-level failures to Exceptional with the Rake task name' do
    Plink::UserReverificationRecord.stub(:incomplete).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/remove_accounts_with_expired_reverifications/)

    subject.invoke
  end

  it 'does not include user.id in the task-level exception text' do
    Plink::UserReverificationRecord.stub(:incomplete).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end

  it 'does not include user_reverification_record.id in the task-level exception text' do
    Plink::UserReverificationRecord.stub(:incomplete).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_not_receive(:handle).with(/user_reverification_record\.id = \d+/)

    subject.invoke
  end
end

describe 'reverifications:set_status_code_108_to_completed' do
  include_context 'rake'

  let!(:user) { create_user }
  let!(:intuit_error) { create_intuit_error(intuit_error_id: 108)}
  let!(:users_intuit_error) { create_user_intuit_error(user_id: user.id, intuit_error_id: intuit_error.id) }
  let!(:reverification) { create_user_reverification(user_id: user.id, users_intuit_error_id: users_intuit_error.id, completed_on: nil, users_institution_id: users_institution.id) }

  let!(:institution) { create_institution(intuit_institution_id: 100000) }
  let!(:users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }

  let!(:intuit_response) do
    { :status_code=>"200",
      :result=>{
        :account_list=>{
          :credit_account=>{
            :account_id=>"400010242913",
            :status=>"ACTIVE",
            :account_number=>"4100007777",
            :account_nickname=>"My Visa",
            :display_position=>"2",
            :institution_id=>"100000",
            :balance_date=>"2013-12-12T00:00:00-08:00",
            :last_txn_date=>"2013-12-10T00:00:00-08:00",
            :aggr_success_date=>"2013-12-12T10:25:20.543-08:00",
            :aggr_attempt_date=>"2013-12-12T10:25:20.543-08:00",
            :aggr_status_code=>"0",
            :currency_code=>"USD",
            :institution_login_id=>"158350175",
            :credit_account_type=>"CREDITCARD",
            :current_balance=>"-1212.25",
            :payment_min_amount=>"15",
            :payment_due_date=>"2020-04-01T00:00:00-07:00",
            :statement_end_date=>"2020-03-01T00:00:00-08:00",
            :statement_close_balance=>"-1212.25"
          }
        }
      }
    }
  end

  let(:intuit_request) { double('Intuit::Request') }

  before do
    create_oauth_token(user_id: user.id)
    create_users_institution_account(account_id: 400010242913, user_id: user.id, users_institution_id: users_institution.id)
    Intuit::Request.stub(:new).and_return(intuit_request)
  end

  it 'does not effect completed reverifications' do
    intuit_request.stub(:account).and_return(intuit_response)
    two_day_ago = 2.days.ago
    completed_reverification = create_user_reverification(user_id: user.id, users_intuit_error_id: users_intuit_error.id, completed_on: two_day_ago, users_institution_id: users_institution.id)

    capture_stdout { subject.invoke }

    completed_reverification.reload.completed_on.to_date.should == two_day_ago.to_date
  end

  it 'does not effect non-108 status code reverifications' do
    intuit_request.stub(:account).and_return(intuit_response)

    intuit_error = create_intuit_error(intuit_error_id: 101)
    users_intuit_error = create_user_intuit_error(user_id: user.id, intuit_error_id: intuit_error.id)
    different_reverification = create_user_reverification(user_id: user.id, users_intuit_error_id: users_intuit_error.id, completed_on: nil, users_institution_id: users_institution.id)

    capture_stdout { subject.invoke }

    different_reverification.reload.completed_on.should be_nil
  end

  it 'calls to intuit to get the account status' do
    intuit_request.should_receive(:account).with(400010242913).and_return(intuit_response)

    capture_stdout { subject.invoke }
  end

  it 'logs record-level exceptions to Exceptional with the Rake task name' do
    Plink::IntuitAccountService.stub(:new).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/set_status_code_108_to_completed/)

    subject.invoke
  end

  it 'includes the user.id in the record-level exception text' do
    Plink::IntuitAccountService.stub(:new).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end

  it 'includes the reverification.id in the record-level exception text' do
    Plink::IntuitAccountService.stub(:new).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/reverification\.id = \d+/)

    subject.invoke
  end

  it 'logs Rake task-level failures to Exceptional with the Rake task name' do
    Plink::UserReverificationRecord.stub(:select).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/set_status_code_108_to_completed/)

    subject.invoke
  end

  it 'does not include user.id in the task-level exception text' do
    Plink::UserReverificationRecord.stub(:select).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end

  it 'does not include reverification.id in the task-level exception text' do
    Plink::UserReverificationRecord.stub(:select).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_not_receive(:handle).with(/reverification\.id = \d+/)

    subject.invoke
  end

  context 'for a user who has a non-108 aggr_status_code' do
    it 'sets the completed_on time for the reverification' do
      intuit_request.should_receive(:account).and_return(intuit_response)
      reverification.completed_on.should be_nil

      capture_stdout { subject.invoke }

      reverification.reload.completed_on.to_date.should == Date.current
    end

    it 'logs a success message' do
      intuit_request.stub(:account).and_return(intuit_response)
      output = capture_stdout { subject.invoke }

      output.should =~ /SUCCESS: Updated reverification_id: /
    end
  end

  context 'for a user who still has a 108 status code' do
    before do
      intuit_response[:result][:account_list][:credit_account][:aggr_status_code] = "108"
    end

    it 'does not update the reverification' do
      intuit_request.should_receive(:account).and_return(intuit_response)

      capture_stdout { subject.invoke }

      reverification.reload.completed_on.should be_nil
    end

    it 'logs a warning message that the user still has that status code' do
      intuit_request.stub(:account).and_return(intuit_response)
      output = capture_stdout { subject.invoke }

      output.should =~ /WARNING: Status code 108 still exists for user_id: /
    end
  end

  context 'with an error response from intuit' do
    it 'logs that an error occurred' do
      failure_response = {
        :status_code=>"203",
        :result=>{
          :status=>{
            :error_info=>{
              :error_message=>"This is an error"
            }
          }
        }
      }
      intuit_request.stub(:account).and_return(failure_response)

      output = capture_stdout { subject.invoke }
      output.should =~ /ERROR: Could not retrieve data from Intuit/
    end
  end
end
