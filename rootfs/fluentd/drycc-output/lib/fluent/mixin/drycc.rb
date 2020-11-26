require 'json'
require 'nsq'
require 'influxdb'
require 'yajl/json_gem'

module Fluent
  module Mixin
    module Drycc
      LOGGER_URL = "http://#{ENV['DRYCC_LOGGER_SERVICE_HOST']}:#{ENV['DRYCC_LOGGER_SERVICE_PORT_HTTP']}/logs"
      INFLUX_HOST = "#{ENV['DRYCC_INFLUXDB_SERVICE_HOST']}"
      INFLUX_PORT = "#{ENV['DRYCC_INFLUXDB_SERVICE_PORT_TRANSPORT']}"
      INFLUX_DATABASE = ENV['INFLUX_DATABASE'] || "kubernetes"
      NSQ_URLs = "#{ENV['DRYCC_NSQD_ADDRS']}".split(",")

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

      def push(producer, value)
        begin
          if value.kind_of? Hash
            producer.write(JSON.dump(value))
          else
            producer.write(value)
          end
        rescue Exception => e
          puts "Error:#{e.message}"
          puts e.backtrace
        end
      end

      def debug?
        ENV["DEBUG"] == "true"
      end

      def get_nsq_producer(topic)
        begin
          puts "Creating nsq producer (#{NSQ_URLs}) for topic:#{topic}"
          return Nsq::Producer.new(nsqd: NSQ_URLs, topic: topic)
        rescue Exception => e
          puts "Error:#{e.message}"
          return nil
        end
      end
    end
  end
end
