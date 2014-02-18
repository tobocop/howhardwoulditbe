require 'spec_helper'

describe AWS::S3UploadService do
  let(:my_file) { double }
  let(:aws) { double }

  before do
    AWS::S3.stub_chain(:new, :buckets, :[]).and_return(aws)
  end

  describe 'initialize' do
    it 'initializes with a bucket name and file' do
      upload_service = AWS::S3UploadService.new('bucket', my_file)
      upload_service.bucket_name.should == 'bucket'
      upload_service.file.should == my_file
    end

    it 'sets up an aws object with the bucket name' do
      s3 = double(:s3)
      buckets = double(:buckets)

      AWS::S3.should_receive(:new).and_return(s3)
      s3.should_receive(:buckets).and_return(buckets)
      buckets.should_receive(:[]).with('bucket').and_return(aws)

      upload_service = AWS::S3UploadService.new('bucket', my_file)
      upload_service.aws.should == aws
    end
  end

  describe '#upload_unique_csv' do
    let(:objects_hash_key) { double(:objects_hash_key, write: true) }
    let(:objects) { double(:objects, { :[] => objects_hash_key }) }

    subject(:aws_s3_upload_service) { AWS::S3UploadService.new('bucket', my_file) }

    before do
      aws.stub(:objects).and_return(objects)
    end

    it 'gets the object to be upload' do
      aws.should_receive(:objects).and_return(objects)

      aws_s3_upload_service.upload_unique_csv
    end

    it 'generates a random csv file name' do
      test_time = Time.zone.now
      Time.stub(:zone).and_return(double(now: test_time))
      file_name = "#{test_time}.csv"

      objects.should_receive(:[]).with(file_name).and_return(objects_hash_key)

      aws_s3_upload_service.upload_unique_csv
    end

    it 'writes the file it was initialized with' do
      objects_hash_key.should_receive(:write).with(file: my_file)

      aws_s3_upload_service.upload_unique_csv
    end
  end
end
