require 'spec_helper'

describe 'social_data:upload_to_s3' do
  include_context 'rake'

  let(:like) { {'name' => 'herp', 'category' => 'something', 'time' => 'timing'} }
  let(:users_social_profile) { double(Plink::UsersSocialProfileRecord, id: 23, user_id: 1, likes: [like, like, like], destroy: true) }
  let(:users_social_profiles) { [users_social_profile] }
  let(:file) { double(Tempfile, puts: true, close: true) }
  let(:aws_s3_upload_service) { double(AWS::S3UploadService, upload_unique_csv: true) }

  before do
    Plink::UsersSocialProfileRecord.stub(:limit).and_return(users_social_profiles)
    Tempfile.stub(:open).and_return(file)
    AWS::S3UploadService.stub(:new).and_return(aws_s3_upload_service)
  end

  context 'when the job has no exceptions' do
    before { ::Exceptional::Catcher.should_not_receive(:handle) }

    it 'gets 10 social profiles' do
      Plink::UsersSocialProfileRecord.should_receive(:limit).with(10).and_return(users_social_profiles)

      subject.invoke
    end

    it 'uses a tempfile to write records' do
      Tempfile.should_receive(:open).and_return(file)

      subject.invoke
    end

    it 'writes the header and entires to the tempfile' do
      file.should_receive(:puts).with("'user_id','like_name','category','like_date'")
      file.should_receive(:puts).with("'1','herp','something','timing'").exactly(3).times

      subject.invoke
    end

    it 'closes the temp file' do
      file.should_receive(:close)

      subject.invoke
    end

    it 'uploads the file to s3' do
      AWS::S3UploadService.should_receive(:new).with('plink-social-profiles', file).and_return(aws_s3_upload_service)
      aws_s3_upload_service.should_receive(:upload_unique_csv)

      subject.invoke
    end

    it 'deletes the social profiles that were uploaded' do
      users_social_profile.should_receive(:destroy)

      subject.invoke
    end
  end

  context 'when there are exceptions' do
    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::UsersSocialProfileRecord.stub(:limit).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /social_data:upload_to_s3/
      end

      subject.invoke
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      users_social_profile.stub(:likes).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /social_data:upload_to_s3 Rake task failed on users_social_profile\.id =/
      end

      subject.invoke
    end
  end
end

