# Flume [![Build Status](https://travis-ci.org/PrintReleaf/flume.png?branch=master)](https://travis-ci.org/PrintReleaf/flume)

An unfancy Redis logger for Ruby.

Works great with Rails, auto-truncates logs at a configurable size, and has a dead-simple CLI for tailing.

### Usage:

**Rails**:

```ruby
# config/application.rb
# or config/environments/{development|production|etc}.rb

config.logger = Flume.logger do |logger|
  logger.redis = Redis.new
  logger.list  = "#{Rails.env}:log"
  logger.cap   = 2 ** 16
end
```

**Plain Old Ruby**:

```ruby
redis  = Redis.new
logger = Flume.logger redis: redis, list: 'myapp:log'
logger.write("my message")

# Alternatively, it can be configured with a block:

logger = Flume.logger do |config|
  config.redis = Redis.new
  config.list  = 'myapp:log'
end

# Or in combination:

logger = Flume.logger list: 'myapp:log' do |config|
  config.redis { Redis.new }
end
```

### Options:

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
      <th>Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>:redis</td>
      <td>Redis instance to use</td>
      <td>Redis.new</td>
    </tr>

    <tr>
      <td>:list</td>
      <td>Redis list to write to</td>
      <td>'flume:log'</td>
    </tr>

    <tr>
      <td>:cap</td>
      <td>Truncation size</td>
      <td>2 ** 16</td>
    </tr>

    <tr>
      <td>:step</td>
      <td>Truncation step</td>
      <td>0</td>
    </tr>

    <tr>
      <td>:cycle</td>
      <td>Truncation cyle</td>
      <td>2 ** 8</td>
    </tr>
  </tbody>
</table>


### CLI:

```bash
$ flume tail myapp:list
$ flume tail myapp:list -f
$ flume tail myapp:list -n 1000
```

To specify which Redis:

```bash
$ REDIS_URL=redis://12.34.56.78:9101 flume tail myapp:list
```


### Why log to Redis?

Redis is cheap, ubiquitous, and centralized in most deployments, making it a lightweight log target for tiny-to-small webapps. Also, its [PubSub](http://redis.io/topics/pubsub) feature is perfect for tailing a list-based log.


## Installation

Add this line to your application's Gemfile:

    gem 'flume'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flume


## Contributing

1. Fork it ( https://github.com/PrintReleaf/flume/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Shout out to @ahoward for [Ledis](https://github.com/ahoward/ledis). Flume started as a fork and owes its simplicity to Ledis's K.I.S.S approach.

## License

MIT

