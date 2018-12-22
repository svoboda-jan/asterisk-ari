require 'asterisk/ari/client'

# instantiate client
@client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

# list all channels
channels = @client.channels.list
if channels.any?
  puts 'Current channels:'
  channels.each { |a| puts a.name }
else
  puts 'No channels currently :-('
end

# listen to events
@client.on :websocket_open do
  puts "Connected !"
end

@client.on :stasis_start do |e|
  e.channel.answer

  e.channel.instance_variables.each { |k| puts "#{k}: #{e.channel.instance_variable_get(k)}" }

  e.channel.on :stasis_end do |e|
    puts "Channel #{e.channel.name} left Stasis."
  end
end

@client.on :stasis_end do
  puts "Left Stasis !"
end

# start websocket to receive events
@client.connect_websocket
sleep 60
@client.ws.close