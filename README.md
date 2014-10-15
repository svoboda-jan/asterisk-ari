[![Build Status](https://secure.travis-ci.org/svoboda-jan/asterisk-ari.png?branch=master)](http://travis-ci.org/svoboda-jan/asterisk-ari)

# About

This repository contains the ruby client library for the Asterisk REST Interface (ARI).
It uses the swagger ARI json definitions to generate ruby classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'asterisk-ari-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asterisk-ari-client

## Usage

```ruby
# instantiate client
@client = Ari::Client.new(
  url: 'http://127.0.0.1:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'my-app'
)

# originate
@client.channels.originate endpoint: 'PJSIP/endpoint-name', extension: 11

# list all channels
channels = @client.channels.list
```

When working with only one client you can also use the following:

```ruby
Ari.client = Ari::Client.new(
  url: 'http://127.0.0.1:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'my-app'
)

# list channels
channels = Ari::Channel.list
```

### WebSocket events

```ruby
# listen to events
@client.on :websocket_open do
  puts "Connected !"
end

@client.on :stasis_start do |e|
  puts "Received call to #{e.channel.dialplan.exten} !"
  
  e.channel.answer

  e.channel.on :channel_dtmf_received do |e|
    puts "Digit pressed: #{e.digit} on channel #{e.channel.name} !"
  end

  e.channel.on :stasis_end do |e|
    puts "Channel #{e.channel.name} left Stasis."
  end
end

# start websocket to receive events
@client.connect_websocket
sleep
```

## Contributing

1. Fork it ( https://github.com/svoboda-jan/asterisk-ari/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
