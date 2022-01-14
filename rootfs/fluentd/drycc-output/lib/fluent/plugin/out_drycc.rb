require 'fluent/mixin/config_placeholders'
require 'fluent/mixin/plaintextformatter'
require 'fluent/mixin/rewrite_tag_name'
require 'fluent/mixin/drycc'
require 'fluent/output'

module Fluent
  class DryccOutput < Output
    Fluent::Plugin.register_output("drycc", self)

    include Fluent::Mixin::PlainTextFormatter
    include Fluent::Mixin::ConfigPlaceholders
    include Fluent::HandleTagNameMixin
    include Fluent::Mixin::RewriteTagName
    include Fluent::Mixin::Drycc

    config_param :tag, :string, :default => ""
    config_set_default :output_include_time, false
    config_set_default :output_include_tag, false
    config_set_default :num_threads, 5
    config_set_default :flush_thread_count, 5

    def initialize
      super
      @logger_redis = nil
      @redis_log_stream = ENV['REDIS_LOG_STREAM'] || "logs"
      @send_logs_to_redis = ENV['SEND_LOGS_TO_REDIS'].to_s.downcase == 'false' ? false : true
    end

    def start
      super
    end

    def shutdown
      super
      @logger_redis.terminate if @logger_redis
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        if from_controller?(record) || drycc_deployed_app?(record)
          @logger_redis ||= get_redis_producer()
          record["time"] = Time.now().strftime("%FT%T.%6N%:z")
          push(@logger_redis, @redis_log_stream, record) if @send_logs_to_redis && @logger_redis
        end
      end
      chain.next
    end
  end
end
