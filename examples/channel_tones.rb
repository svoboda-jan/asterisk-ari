require 'asterisk/ari/client'
require 'securerandom'

# instantiate client
@client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

$channel_timers = {}

# Callback that will actually answer the channel
#
def answer_channel(channel,playback)
  puts "Answering channel #{channel.name}"

  playback.stop
  channel.answer

  # Hang up the channel in 1 seconds
  timer = Thread.new { sleep 1; hangup_channel(channel) }
  $channel_timers[channel.id] = timer
end

# Callback that will actually hangup the channel
#
def hangup_channel(channel)
  puts "Hanging up channel #{channel.name}"
  channel.hangup
end
  
# listen to events
@client.on :websocket_open do
  puts "Connected !"
end

@client.on :stasis_start do |e|
  puts "Channel #{e.channel.name} has entered the application"
  playback_id = SecureRandom.uuid
  playback = e.channel.play_with_id(channelId: e.channel.id, playbackId: playback_id,
                                  media: 'tone:ring;tonezone=fr')
  # Answer the channel after 8 seconds
  timer = Thread.new { sleep 8; answer_channel(e.channel,playback) }
  $channel_timers[e.channel.id] = timer
  
  e.channel.on :stasis_end do |e|
    puts "Channel #{e.channel.name} left Stasis."
    
    # Cancel any pending timers
    if $channel_timers.has_key?(e.channel.id)
      timer = $channel_timers[e.channel.id]
      timer.kill
      $channel_timers.delete(e.channel.id)
    end
  end
end

# start websocket to receive events
@client.connect_websocket
sleep