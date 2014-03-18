require 'spec_helper'

describe Plink::PendingJobRecord do
  it { should allow_mass_assignment_of(:begin_date) }
  it { should allow_mass_assignment_of(:begin_user_id) }
  it { should allow_mass_assignment_of(:command_template) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:end_user_id) }
  it { should allow_mass_assignment_of(:fishy_user_id) }
  it { should allow_mass_assignment_of(:is_blocking) }
  it { should allow_mass_assignment_of(:is_serial) }
  it { should allow_mass_assignment_of(:job_queue_id) }
  it { should allow_mass_assignment_of(:notification_list) }

  let(:valid_params) {
    {
      begin_date: nil,
      begin_user_id: 2,
      command_template: 'something',
      end_date: nil,
      end_user_id: 2,
      fishy_user_id: 9 ,
      is_blocking: false,
      is_serial: false,
      notification_list: nil
    }
  }

  it 'can be persisted' do
    Plink::PendingJobRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:begin_user_id) }
    it { should validate_presence_of(:command_template) }
    it { should validate_presence_of(:end_user_id) }
  end

  describe '.create_fishy' do
    it 'creates a job with the correct params given 2 user ids' do
      fishy_job = Plink::PendingJobRecord.create_fishy(1, 2)
      fishy_job.begin_date.should be_nil
      fishy_job.begin_user_id.should == 1
      fishy_job.command_template.should == '$FISHY_COMMAND --environment $ENVIRONMENT -c $CONFIG_DIR -v -Q $JOB_QUEUE_ID --primary $PRIMARY_USER_ID --user_id $FISHY_USER_ID'
      fishy_job.end_date.should be_nil
      fishy_job.end_user_id.should == 1
      fishy_job.fishy_user_id.should == 2
      fishy_job.is_active.should be_true
      fishy_job.is_blocking.should be_false
      fishy_job.is_serial.should be_false
      fishy_job.job_queue_id.should be_nil
      fishy_job.notification_list.should be_nil
      fishy_job.should be_persisted
    end
  end

  describe '#pending?' do
    it 'returns true if job_queue_id is blank' do
      Plink::PendingJobRecord.new.pending?.should be_true
    end

    it 'returns false if job_queue_id is present' do
      Plink::PendingJobRecord.new(job_queue_id: 2).pending?.should be_false
    end
  end
end
