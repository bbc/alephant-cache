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

    def put(id, data, content_type = 'text/plain', meta = {})
      bucket.objects["#{path}/#{id}"].write(
        data,
        {
          :content_type => content_type,
          :metadata     => meta
        }
      )

      logger.metric "CachePuts"
      logger.info("Cache.put: #{path}/#{id}")
    end

    def get(id)
      logger.metric "CacheGets"
      logger.info("Cache.get: #{path}/#{id}")
      object = bucket.objects["#{path}/#{id}"]

      {
        :content      => object.read,
        :content_type => object.content_type,
        :meta         => object.metadata.to_h
      }
    end
  end
end

