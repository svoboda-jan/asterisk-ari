require 'asterisk/ari/client'

# instantiate client
@client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

$channel_timers = {}

# Callback that will actually answer the channel
#
def answer_channel(channel)
  puts "Answering channel #{channel.name}"

  channel.answer
  channel.start_silence

  # Hang up the channel in 4 seconds
  timer = Thread.new { sleep 4; hangup_channel(channel) }
  $channel_timers[channel.id] = timer
end

# Callback that will actually hangup the channel
#
def hangup_channel(channel)
  puts "Hanging up channel #{channel.name}"
  channel.hangup 
end
  
# Handler for changes in a channel's state
#
def channel_state_change_cb(channel, ev)
  puts "Channel #{channel.name} is now: #{channel.state}"
end

# listen to events
@client.on :websocket_open do
  puts "Connected !"
end

@client.on :channel_state_change do |e|
  puts "Channel2 #{e.channel.name} is now: #{e.channel.state}"
end

@client.on :stasis_start do |e|
  puts "Channel #{e.channel.name} has entered the application"

  e.channel.ring
  # Answer the channel after 8 seconds
  timer = Thread.new { sleep 8; answer_channel(e.channel) }
  $channel_timers[e.channel.id] = timer

  e.channel.on :channel_state_change do |e|
    channel_state_change_cb(e.channel)
  end

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