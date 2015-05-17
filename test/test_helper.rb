#$VERBOSE = true

require 'minitest/autorun'
#require 'minitest/pride'
require 'webmock/minitest'
require 'vcr'
require 'pp'

module PrettyJSONWithPrettyBody
  include VCR::Cassette::Serializers::JSON
  extend self
  extend VCR::Cassette::EncodingErrorHandling
  def serialize(hash)
    handle_encoding_errors do
      hash["http_interactions"].each do |interaction|
        body_hash = MultiJson.load(interaction["response"]["body"]["string"])
        interaction["response"]["body"]["string"] = body_hash
      end
      ::JSON.pretty_generate(hash)
    end
  end
  def deserialize(string)
    handle_encoding_errors do
      hash = MultiJson.decode(string)
      hash["http_interactions"].each do |interaction|
        body_string = ::JSON.pretty_generate(interaction["response"]["body"]["string"])
        interaction["response"]["body"]["string"] = body_string
      end
      hash
    end
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
  c.cassette_serializers[:pretty_json_with_pretty_body] = PrettyJSONWithPrettyBody
  c.default_cassette_options = {
    serialize_with: :pretty_json_with_pretty_body,
    match_requests_on:  [ :method, :path ]
  }
end

require File.expand_path('../../lib/asterisk/ari/client.rb', __FILE__)
