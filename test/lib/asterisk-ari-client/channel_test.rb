require_relative '../../test_helper'

class TestChannel < Minitest::Test
  def setup
    @client = Ari::Client.new(
      url: 'http://192.168.1.23:8088/ari',
      api_key: 'asterisk:asterisk',
      app: 'dialplan'
    )
  end

  def test_list
    VCR.use_cassette 'channels_list' do
      channels = @client.channels.list

      assert_kind_of Array, channels
      assert_equal 2, channels.length

      assert_kind_of Ari::Channel, channels.first

      assert_equal '1412483829.18', channels.first.id
      assert_equal '1412483873.19', channels.last.id
    end
  end

  def test_originate
    VCR.use_cassette 'channel_originate' do
      channel = @client.channels.originate endpoint: 'PJSIP/1ca410-mac', extension: 11

      assert_kind_of Ari::Channel, channel
      assert_equal '1412483873.19', channel.id
      assert_equal 's', channel.dialplan.exten
    end
  end

  def test_originate_with_id
    VCR.use_cassette 'channel_originate_with_id' do
      channel = @client.channels.originate({
        endpoint: 'PJSIP/1ca410-mac',
        extension: 11,
        channelId: 'cb07847a-595b-48ff-857b-b7a78893fd83'
      })

      assert_kind_of Ari::Channel, channel
      assert_equal 'cb07847a-595b-48ff-857b-b7a78893fd83', channel.id
      assert_equal 's', channel.dialplan.exten
    end
  end

  def test_get
    VCR.use_cassette 'channel_get' do
      channel = @client.channels.get channelId: '1412509919.30'

      assert_kind_of Ari::Channel, channel
      assert_equal '1412509919.30', channel.id
    end
  end

  def test_originate_with_channel_vars
    VCR.use_cassette 'channel_originate_with_channel_vars' do
      channel = @client.channels.originate({
        endpoint: 'PJSIP/1ca410-mac',
        extension: 11,
        body: { variables: { my_var: 'my_value' } }
      })

      assert_kind_of Ari::Channel, channel

      # TODO here channel needs to be in Stasis app (answered)

      channel_var = channel.get_channel_var variable: 'my_var'

      assert_equal 'my_value', channel_var.value
    end
  end

end
