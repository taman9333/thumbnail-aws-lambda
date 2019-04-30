require "aws-sdk-s3"
require "mini_magick"

def hello(event:, context:)
  event = event["Records"].first
  bucket_name = event["s3"]["bucket"]["name"]
  object_name = event["s3"]["object"]["key"]
  return if object_name.split('-').first == 'thumbnail'

  s3 = Aws::S3::Client.new
  resp = s3.get_object(bucket:bucket_name, key:object_name)
  img = MiniMagick::Image.read resp.body
  size = ENV['THUMBNAIL_SIZE']
  img.resize "#{size}x#{size}"
  resized_tmp_file = "/tmp/resized.png"
  img.write resized_tmp_file

  s3 = Aws::S3::Resource.new
  s3.bucket(bucket_name).object("thumbnail-#{object_name}").upload_file(resized_tmp_file)
  puts '-------------------------------------------'
  puts "Image successfully upload to your s3 bucket"
end