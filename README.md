# Alephant::Cache

Simple abstraction layer over S3 for get/put.

## Installation

Add this line to your application's Gemfile:

    gem 'alephant-cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alephant-cache

## Usage

```rb
require 'alephant/cache'

cache = Alephant::Cache.new('bucket_id', 'base/path')
cache.put('id', "string data")
cache.get('id')

# => "string data"
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/alephant-cache/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
