require 'asterisk-ari-client'

@client = Ari::Client.new(
  url: 'http://192.168.1.23:8088/ari',
  api_key: 'asterisk:asterisk',
  app: 'dialplan'
)

# list channels
channels = @client.channels.list

channels.each do |channel|
  puts "Channel ID #{channel.id}: #{channel.name}"
end
