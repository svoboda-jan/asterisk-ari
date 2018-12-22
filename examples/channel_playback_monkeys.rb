require 'asterisk/ari/client'
require 'securerandom'

# instantiate client
@client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

# listen to events
@client.on :websocket_open do
  puts "Connected !"
end

@client.on :stasis_start do |e|
  puts "Monkeys! Attack Channel #{e.channel.name} !"
  playback_id = SecureRandom.uuid
  playback = e.channel.play_with_id(channelId: e.channel.id, playbackId: playback_id,
                                  media: 'sound:tt-monkeys')
  
  playback.on :playback_finished do |p|
    puts "Monkeys successfully vanquished #{e.channel.name} hanging them up"
    e.channel.hangup
  end

  e.channel.on :stasis_end do |e|
    puts "Channel #{e.channel.name} left Stasis."
  end
end

# start websocket to receive events
@client.connect_websocket
sleep
