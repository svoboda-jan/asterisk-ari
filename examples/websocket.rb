require 'asterisk-ari-client'

Ari.client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

@client.on :websocket_open do
  puts "Connected !"
end

@client.on :websocket_error do |err|
  puts "Error :( #{err}"
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
