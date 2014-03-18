require 'spec_helper'

describe PlinkAdmin::FishyJobsController do
  let(:admin) { create_admin }
  let!(:pending_job) { create_pending_job }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all pending_jobs in the database' do
      assigns(:pending_jobs).should == [pending_job]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new pending_job' do
      assigns(:pending_job).should be_present
      assigns(:pending_job).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a pending_job record and redirects to the listing when successful' do
      pending_job_params = {
        begin_user_id: 3,
        fishy_user_id: nil
      }

      post :create, {fishy_job: pending_job_params}
      fishy_job = Plink::PendingJobRecord.last
      fishy_job.begin_user_id.should == 3
      fishy_job.end_user_id.should == 3
      fishy_job.fishy_user_id.should be_nil
      flash[:notice].should == 'Fishy job created successfully'

      response.should redirect_to '/fishy_jobs'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::PendingJobRecord.stub(:create).and_return(double(persisted?: false))

      post :create, {fishy_job: {begin_user_id: 3, fishy_user_id: nil}}

      flash[:notice].should == 'Fishy job could not be created'
      response.should render_template 'new'
    end
  end
end
