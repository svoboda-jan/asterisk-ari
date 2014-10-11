require_relative '../../test_helper'

class TestBridge < Minitest::Test
  def setup
    @client = Ari::Client.new(
      url: 'http://192.168.1.23:8088/ari',
      api_key: 'asterisk:asterisk',
      app: 'dialplan'
    )
  end

  def test_list
    VCR.use_cassette 'bridges_list' do
      bridges = @client.bridges.list

      assert_kind_of Array, bridges
      assert_equal 1, bridges.length

      assert_kind_of Ari::Bridge, bridges.first

      assert_equal '88301dbb-538a-4460-9c5d-bb659c48b320', bridges.first.id
    end
  end

  def test_create
    VCR.use_cassette 'bridge_create' do
      bridge = @client.bridges.create type: 'mixing,dtmf_events'

      assert_kind_of Ari::Bridge, bridge
      assert_equal '310e4c2d-85cc-4267-90e4-491217040d80', bridge.id
      assert_equal 'mixing', bridge.bridge_type
    end
  end

  def test_get
    VCR.use_cassette 'bridge_get' do
      bridge = @client.bridges.get bridgeId: '310e4c2d-85cc-4267-90e4-491217040d80'

      assert_kind_of Ari::Bridge, bridge
      assert_equal '310e4c2d-85cc-4267-90e4-491217040d80', bridge.id
      assert_equal 'mixing', bridge.bridge_type
      assert_equal 'simple_bridge', bridge.technology
    end
  end

end
