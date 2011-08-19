# YAML Adapter for using a redis client store
# YamlRecord::Adapters::RedisStore.new(@redis)

module YamlRecord
  module Adapters
    class RedisStore
      attr_reader :client

      # client is an instantiated redis client (i.e Redis::Client.new(...))
      def initialize(client)
        raise "Please specify a Redis client" unless client
        @client = client
      end

      # Returns Redis YML data as ruby collection
      #
      # === Example:
      #
      #   @adapter.read("foo") => [{...}, {...}]
      #
      def read(source)
        YAML.load(@client.get(redis_key(source)).to_s)
      end

      # Writes ruby collection as Redis YML data
      #
      # === Example:
      #
      #   @adapter.write("foo", [{...}, {...}]) => "<yaml data>"
      #
      def write(source, collection)
        @client.set(redis_key(source), collection.to_yaml)
      end

      private

      def redis_key(source)
        "yaml_record:" + source
      end
    end
  end
end