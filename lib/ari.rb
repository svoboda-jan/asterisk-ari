module Ari

  def self.client
    return @@client if defined?(@@client)
    raise "ARI client not set. You can set it with ARI.client = client."
  end

  def self.client=(val)
    @@client = val
  end

end
