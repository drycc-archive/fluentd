require 'json'
require 'redis'

module Fluent
  module Mixin
    module Drycc
      REDIS_CONNECTIONS = []
      "#{ENV['DRYCC_REDIS_ADDRS']}".split(",").each do |address|
        REDIS_CONNECTIONS.append(Redis.new(url: "redis://:#{ENV['DRYCC_REDIS_PASSWORD']}@#{address}"))
      end
      LOG_MAX_LINES = ENV.fetch('LOG_MAX_LINES',"1000").to_i

      def kubernetes?(message)
        return message["kubernetes"] != nil
      end

      def from_controller?(message)
        if from_container?(message, "drycc-controller")
          return message["log"] =~ /^(INFO|WARN|DEBUG|ERROR)\s+(\[(\S+)\])+:(.*)/
        end
        return false
      end

      def from_container?(message, regex)
        if kubernetes? message
          return true if Regexp.new(regex).match(message["kubernetes"]["container_name"]) != nil
        end
        return false
      end

      def drycc_deployed_app?(message)
        if kubernetes? message
          labels = message["kubernetes"]["labels"]
          return true if message["kubernetes"]["namespace_name"] != "drycc" && labels["heritage"] == "drycc" && labels["app"] != nil
        end
        return false
      end

      def push(redis, stream, values)
        begin
          redis.xtrim(stream, LOG_MAX_LINES, approximate: true)
          if values.kind_of? Hash
            redis.xadd(stream, {data: JSON.dump(values), timestamp: Time.now.to_i})
          else
            redis.xadd(stream, {data: values, timestamp: Time.now.to_i})
          end
        rescue Exception => e
          puts "Error:#{e.message}"
          puts e.backtrace
        end
      end

      def debug?
        ENV["DEBUG"] == "true"
      end

      def get_redis_producer()
        begin
          puts "Creating redis producer"
          return REDIS_CONNECTIONS[rand(REDIS_CONNECTIONS.count)]
        rescue Exception => e
          puts "Error:#{e.message}"
          return nil
        end
      end
    end
  end
end
