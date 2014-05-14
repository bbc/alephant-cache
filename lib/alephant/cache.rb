require 'alephant/cache/version'
require 'alephant/logger'
require 'aws-sdk'

module Alephant
  class Cache
    include Logger
    attr_reader :id, :bucket, :path

    def initialize(id, path)
      @id = id
      @path = path

      @bucket = AWS::S3.new.buckets[id]
      logger.info("Cache.initialize: end with id #{id} and path #{path}")
    end

    def clear
      bucket.objects.with_prefix(path).delete_all
      logger.info("Cache.clear: #{path}")
    end

    def put(id, data, meta = {})
      bucket.objects["#{path}/#{id}"].write(
        data,
        {
          :metadata => meta
        }
      )

      logger.info("Cache.put: #{path}/#{id}")
    end

    def get(id)
      logger.info("Cache.get: #{path}/#{id}")
      bucket.objects["#{path}/#{id}"].read
    end
  end
end
