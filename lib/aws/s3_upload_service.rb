module AWS
  class S3UploadService
    attr_accessor :aws, :bucket_name, :file

    def initialize(bucket_name, file)
      @bucket_name = bucket_name
      @file = file
      @aws = AWS::S3.new.buckets[bucket_name]
    end

    def upload_unique_csv
      aws.objects["#{Time.zone.now}.csv"].write(file: file)
    end
  end
end
