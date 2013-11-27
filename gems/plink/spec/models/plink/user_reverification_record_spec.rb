require 'spec_helper'

describe Plink::UserReverificationRecord do
  it { should allow_mass_assignment_of(:completed_on) }
  it { should allow_mass_assignment_of(:intuit_error_id) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:is_notification_successful) }
  it { should allow_mass_assignment_of(:started_on) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:user_saw_question) }
  it { should allow_mass_assignment_of(:users_institution_id) }
  it { should allow_mass_assignment_of(:users_intuit_error_id) }

  it { should belong_to(:user_record) }
  it { should belong_to(:users_institution_record) }
  it { should have_one(:institution_record).through(:users_institution_record) }

  let(:valid_params) {
    {
      completed_on: nil,
      intuit_error_id: 1,
      is_active: true,
      is_notification_successful: false,
      started_on: nil,
      user_id: 1,
      users_institution_id: 1,
      users_intuit_error_id: 1,
      user_saw_question: false
    }
  }

  subject { Plink::UserReverificationRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::UserReverificationRecord.create(valid_params).should be_persisted
  end

  context 'named scopes' do
    describe '.requiring_notice' do
      let!(:user_reverification) {
        create_user_reverification(
          completed_on: nil,
          is_notification_successful: false,
          intuit_error_id: 103
        )
      }
      let(:reverifications) { Plink::UserReverificationRecord.requiring_notice }

      it 'returns un-notified incomplete reverification records' do
        reverifications.length.should == 1
        reverifications.first.id.should == user_reverification.id
      end

      it 'does not return un-notified complete reverification records' do
        user_reverification.update_attribute('completed_on', Time.zone.now)
        reverifications.length.should == 0
      end

      it 'returns notified, incomplete reverification records that were created three days ago' do
        user_reverification.update_attribute('created', 3.days.ago)
        user_reverification.update_attribute('is_notification_successful', true)
        reverifications.length.should == 1
        reverifications.first.id.should == user_reverification.id
      end

      it 'does not return notified, complete reverification records that were created three days ago' do
        user_reverification.update_attribute('created', 3.days.ago)
        user_reverification.update_attributes(is_notification_successful: true, completed_on: Time.zone.now)
        reverifications.length.should == 0
      end
    end

    describe '.incomplete' do
      before do
        create_user_reverification(completed_on: Time.zone.today, is_active: true)
        @expected = create_user_reverification(completed_on: nil, is_active: true)
        create_user_reverification(completed_on: Time.zone.today, is_active: false)
        create_user_reverification(completed_on: nil, is_active: false)
      end

      it 'returns active and not completed reverification records' do
        reverifications = Plink::UserReverificationRecord.incomplete
        reverifications.length.should == 1
        reverifications.should include @expected
      end
    end
  end

  describe '#link' do
    before do
      Plink::UserReverificationRecord.any_instance.stub(:institution_record).
        and_return(double(home_url: 'http://chase.com'))
    end

    it 'returns the institution_records url if the intuit_error_id is 108' do
      reverification = Plink::UserReverificationRecord.new(valid_params.merge(intuit_error_id: 108))
      reverification.link.should == 'http://chase.com'
    end

    it 'returns the institution_records url if the intuit_error_id is 109' do
      reverification = Plink::UserReverificationRecord.new(valid_params.merge(intuit_error_id: 109))
      reverification.link.should == 'http://chase.com'
    end

    it 'returns nil if the intuit_error_id is not 108 or 109' do
      reverification = Plink::UserReverificationRecord.new(valid_params.merge(intuit_error_id: 110))
      reverification.link.should be_nil
    end
  end

  describe '#notice_type' do
    it 'returns initial if the notification has not been sent yet' do
      reverification = Plink::UserReverificationRecord.new(valid_params)
      reverification.notice_type.should == 'initial'
    end

    it 'returns three_day_reminder if the notification has been sent' do
      reverification = Plink::UserReverificationRecord.new(valid_params.merge(is_notification_successful: true))
      reverification.notice_type.should == 'three_day_reminder'
    end
  end
end
