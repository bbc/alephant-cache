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

      logger.info(
        "event"  => "CacheInitialized",
        "id"     => id,
        "path"   => path,
        "method" => "#{self.class}#initialize",
      )
    end

    def clear
      bucket.objects.with_prefix(path).delete_all
      logger.info(
        "event"  => "CacheCleared",
        "path"   => path,
        "method" => "#{self.class}#clear"
      )
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
      logger.info(
        "event"  => "CacheObjectStored",
        "path"   => path,
        "id"     => id,
        "method" => "#{self.class}#put"
      )
    end

    def get(id)
      object       = bucket.objects["#{path}/#{id}"]
      content      = object.read
      content_type = object.content_type
      meta_data    = object.metadata.to_h

      logger.metric "CacheGets"
      logger.info(
        "event"       => "CacheObjectRetrieved",
        "path"        => path,
        "id"          => id,
        "content"     => content,
        "contentType" => content_type,
        "metadata"    => meta_data,
        "method"      => "#{self.class}#get"
      )

      {
        :content      => content,
        :content_type => content_type,
        :meta         => meta_data
      }
    end
  end
end
