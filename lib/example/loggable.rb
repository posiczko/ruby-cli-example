require "logger"

# 1. **Instance method**: - available to instances of the including class `logger`
# 2. **Class method**: - available to the class itself (added via the hook) `logger``included`
module Example

  module Loggable
    class << self
      def logger(config)
        level = (config and config[:debug]) ? Logger::DEBUG : Logger::INFO

        @logger_formatter ||= proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime("%Y-%m-%d %H:%M:%S.%L")
          extra_logging = ""
          if level == Logger::DEBUG
            # Adjust the '4' as needed based on your call stack
            location = caller_locations(4, 1).first
            # For class/module name
            location.base_label
            method_name = location.label
            extra_logging = " -- #{method_name}"
          end

          short_severity = case severity
          when "DEBUG"
            "D"
          when "INFO"
            "I"
          when "WARN"
            "W"
          when "ERROR"
            "E"
          else
            "?"
          end

          "[#{short_severity}] #{date_format}#{extra_logging}: #{msg}\n"
        end

        @logger ||= Logger.new($stdout, formatter: @logger_formatter, level: level)
        @logger
      end

      attr_writer :config

      attr_writer :logger
    end

    def self.included(base)
      class << base
        def logger
          Loggable.logger
        end
      end
    end

    def logger
      Example::Loggable.logger(@config)
    end

    # def logger
    #   level = @options[:debug] ? :debug : :info
    #   @logger ||= Dry.Logger(:stdout, level: level, template: "%{severity}: %{time}:  %{message}")
    # end

    def die(message)
      logger.error(message)
      exit(1)
    end
  end
end
