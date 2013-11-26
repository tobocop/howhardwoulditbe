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

    subject.invoke
  end

  context 'errors that require immediate action' do
    let!(:user_intuit_error) {
      create_user_intuit_error(
        intuit_error_id: 103,
        user_id: user.id,
        users_institution_id: users_institution.id
      )
    }

    it 'immediately queues a reverifciation notice for error code 103' do
      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 103,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      subject.invoke
    end

    it 'immediately queues a reverifciation notice for error code 106' do
      user_intuit_error.update_attribute('intuit_error_id', 106)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 106,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      subject.invoke
    end

    it 'immediately queues a reverifciation notice for error code 108' do
      user_intuit_error.update_attribute('intuit_error_id', 108)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 108,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      subject.invoke
    end

    it 'immediately queues a reverifciation notice for error code 109' do
      user_intuit_error.update_attribute('intuit_error_id', 109)

      Plink::UserReverificationRecord.should_receive(:create).
        with({
          intuit_error_id: 109,
          user_id: user.id,
          users_institution_id: users_institution.id,
          users_intuit_error_id: user_intuit_error.id
        })

      subject.invoke
    end

    it 'does not queue a reverification notice if the users active institution does not match that of the error' do
      user_intuit_error.update_attribute('users_institution_id', old_users_institution.id)

      Plink::UserReverificationRecord.should_not_receive(:create)

      subject.invoke
    end

    it 'does not queue duplicate reverifciation notices' do
      user_intuit_error = create_user_intuit_error(
        intuit_error_id: 103,
        user_id: user.id,
        users_institution_id: users_institution.id
      )

      subject.invoke

      Plink::UserReverificationRecord.all.length.should == 1
    end

    it 'does not queue reverifciation notices to force deactivated members' do
      user.update_attribute('isForceDeactivated', true)

      Plink::UserReverificationRecord.should_not_receive(:create)
      subject.invoke
    end

    it 'does not queue reverifciation notices to white label members' do
      swagbucks = create_virtual_currency(subdomain: 'swagbucks')
      user.primary_virtual_currency = swagbucks
      user.save

      Plink::UserReverificationRecord.should_not_receive(:create)
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

        subject.invoke
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

        subject.invoke
      end

      it 'does not queue a notice if the user has received error code 185 for 4 days in a row' do
        Plink::UserReverificationRecord.should_not_receive(:create)
        subject.invoke
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

        subject.invoke
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

        subject.invoke
      end

      it 'does not queue a notice if the user has received error code 187 for 4 days in a row' do
        Plink::UserReverificationRecord.should_not_receive(:create)
        subject.invoke
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
  end

  it 'emails users who have an unsent notification' do
    AutoLoginService.should_receive(:generate_token)
      .with(user.id)
      .and_return('my_token')
    mailer.should_receive(:notice_email).
      with({
        email: 'myshitisbroken@intuit.com',
        first_name: 'bobby',
        institution_name: 'Bank of AMERRRICA!',
        intuit_error_id: 103,
        reverification_link: nil,
        user_token: 'my_token'
      })

    subject.invoke
  end

  it 'updates the reverification flagging it as notified' do
    mailer.stub(:notice_email)

    subject.invoke

    user_reverification.reload.is_notification_successful.should be_true
  end

  it 'does not email users who have already completed their reverification' do
    user_reverification.update_attribute('completed_on', Time.zone.now)
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end

  it 'does not email users who have already been notified their account needs to be reverified' do
    user_reverification.update_attribute('is_notification_successful', true)
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end

  it 'does not email users who have a different active institution then what is on the reverification' do
    user_reverification.update_attribute('users_institution_id', old_users_institution.id)
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end

  it 'does not email force deactivated users' do
    user.update_attribute('isForceDeactivated', true)
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end

  it 'does not email white label users' do
    swagbucks = create_virtual_currency(subdomain: 'swagbucks')
    user.primary_virtual_currency = swagbucks
    user.save
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end

  it 'does not email unsubscribed users' do
    user.update_attribute('isSubscribed', false)
    mailer.should_not_receive(:notice_email)
    subject.invoke
  end
end
