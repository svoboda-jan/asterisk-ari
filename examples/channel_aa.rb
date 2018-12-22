require 'asterisk/ari/client'

# This example does the following:
# Plays a menu to the user which is cancelled when the user takes some action.
# If the user presses 1 or 2, the digit is repeated to the user and the menu restarted.
# If the user presses an invalid digit, a prompt informing the user that the digit was invalid is played to the user and the menu restarted.
# If the user fails to press anything within some period of time, a prompt asking the user if they are still present is played to the user and the menu restarted.
# 

class UserAction
  
  def initialize(timeout)
    @timeout = timeout
  end
  
  def action(menu,channel)
    # A timer is started for the channel. If the timer pops,
    # a prompt is played back and the menu restarted.
    reset_timer menu, channel
    user = self
    channel.on :channel_dtmf_received do |e|
      # Since they pressed something, cancel the timeout timer
      user.cancel_timer
      menu.stop
      menu.dtmf e, user
    end
  end
  
  def reset_timer(menu,channel)
    @timer = Thread.new do 
      sleep @timeout; 
      menu.stop
      menu.timeout channel, self
    end
  end
  
  def cancel_timer
    @timer.kill
  end
  
end

class MenuState
  
  def initialize(sounds)
    @sounds = sounds
  end
  
  # Play our intro menu to the specified channel
  # Since we want to interrupt the playback of the menu when the user presses
  # a DTMF key, we maintain the state of the menu via the MenuState object.
  # A menu completes in one of two ways:
  #  (1) The user hits a key
  #  (2) The menu finishes to completion
  #
  def play(channel)
    @complete = false
    @current_sound = 0
    queue_up_sound channel
  end

  # Start up the next sound and handle whatever happens
  #
  def queue_up_sound(channel)
    @current_playback = play_next_sound channel
    if @current_playback.nil?
      @complete = true
      return
    end
    @current_sound += 1
    if @current_sound >= @sounds.length
      @complete = true
    end
  end

  # Play the next sound, if we should
  # Returns:
  #  None if no playback should occur
  #  A playback object if a playback was started
  #  
  def play_next_sound(channel)

    return nil if @complete
        
    begin
      media = "sound:#{@sounds[@current_sound]}"
      @current_playback = channel.play(channelId: channel.id, media: media)
      menu = self
      @current_playback.on :playback_finished do |p|
        menu.queue_up_sound channel
      end
    rescue
        @current_playback = nil
    end
  end
  
  # Callback called by a timer when the menu times out
  #
  def timeout(channel,user)
    puts "Channel #{channel.name} stopped paying attention..."
    begin
      channel.play(media: 'sound:are-you-still-there')
      user.reset_timer self,channel
      play channel
    rescue
    end
  end
  
  def dtmf(channel_dtmf,user)
    on_dtmf_received channel_dtmf.channel, channel_dtmf
    play channel_dtmf.channel
    user.reset_timer self,channel_dtmf.channel
  end
  
  # Cancel the menu, as the user did something
  #
  def stop
    @complete = true
  end
  
  # Our main DTMF handler for a channel in the IVR
  #
  def on_dtmf_received(channel, ev)
    digit = ev.digit
    puts "Channel #{channel.name} entered #{digit}"
    if digit == '1'
        handle_extension_one channel
    elsif digit == '2'
        handle_extension_two channel
    else
        puts "Channel #{channel.name} entered an invalid option!"
        channel.play(media:'sound:option-is-invalid')
    end
  end

  # Handler for a channel pressing '1'
  #
  def handle_extension_one(channel)
    channel.play(media:'sound:you-entered')
    channel.play(media:'digits:1')
  end 

  # Handler for a channel pressing '2'
  #
  def handle_extension_two(channel)
    channel.play(media:'sound:you-entered')
    channel.play(media:'digits:2')
  end 
  
end

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

@client.on :stasis_end do |e|
  puts "Channel #{e.channel.name} left Stasis."
end

@client.on :stasis_start do |e|
  puts "Channel #{e.channel.name} has entered the application"
  e.channel.answer

  sleep 2
  
  # note: this uses the 'extra' sounds package
  sounds = ['press-1', 'or', 'press-2']
  menu = MenuState.new sounds
  menu.play e.channel
  timeout = 8
  user = UserAction.new timeout
  user.action menu, e.channel
end

# start websocket to receive events
@client.connect_websocket
sleep

 