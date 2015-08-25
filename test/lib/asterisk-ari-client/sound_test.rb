require_relative '../../test_helper'

class TestSound < Minitest::Test
  def setup
    @client = Ari::Client.new(
      url: 'http://192.168.64.9:8088/ari',
      api_key: 'asterisk:asterisk',
      app: 'dialplan'
    )
  end

  def test_list
    VCR.use_cassette 'sounds_list' do
      sounds = @client.sounds.list

      assert_kind_of Array, sounds
      assert_equal 501, sounds.length

      assert_kind_of Ari::Sound, sounds.first

      assert_equal 'gsm', sounds.first.formats.first.format
      assert_equal 'en', sounds.first.formats.first.language
      assert_equal 'vm-nomore', sounds.first.id
      assert_equal 'No more messages.', sounds.first.text
    end
  end

end
