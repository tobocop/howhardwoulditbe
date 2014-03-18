module PlinkAdmin
  class FishyJobsController < ApplicationController

    def index
      @pending_jobs = Plink::PendingJobRecord.order('id desc').all
    end

    def new
      @pending_job = Plink::PendingJobRecord.new
    end

    def create
      @pending_job = Plink::PendingJobRecord.create_fishy(params[:fishy_job][:begin_user_id], params[:fishy_job][:fishy_user_id])

      if @pending_job.persisted?
        flash[:notice] = 'Fishy job created successfully'
        redirect_to plink_admin.fishy_jobs_path
      else
        flash.now[:notice] = 'Fishy job could not be created'
        render 'new'
      end
    end
  end
end
