module Plink
  class PendingJobRecord < ActiveRecord::Base
    self.table_name = 'pending_jobs'

    attr_accessible :begin_date, :begin_user_id, :command_template, :end_date,
      :end_user_id, :fishy_user_id, :is_blocking, :is_serial, :job_queue_id, :notification_list

    validates_presence_of :begin_user_id, :end_user_id, :command_template

    def self.create_fishy(primary_user_id, fishy_user_id = nil)
      create(
        begin_user_id: primary_user_id,
        end_user_id: primary_user_id,
        fishy_user_id: fishy_user_id,
        command_template: '$FISHY_COMMAND --environment $ENVIRONMENT -c $CONFIG_DIR -v -Q $JOB_QUEUE_ID --primary $PRIMARY_USER_ID --user_id $FISHY_USER_ID'
      )
    end

    def pending?
      job_queue_id.blank?
    end
  end
end
