require "logger"

# Mixin that gives including classes a `logger` instance method backed by a
# shared, level-aware stdlib Logger. The level follows the per-invocation
# `@config[:debug]` flag of the including object.
module Example

  module Loggable
    class << self
      def logger(config)
        level = (config and config[:debug]) ? Logger::DEBUG : Logger::INFO

        # Rebuild only when the level changes. Memoizing unconditionally would
        # freeze in the first caller's level (and the formatter's captured
        # level), so a later --debug run would be ignored.
        if @logger.nil? || @logger.level != level
          @logger = Logger.new($stdout, formatter: formatter(level), level: level)
        end

        @logger
      end

      attr_writer :config

      attr_writer :logger

      private

      def formatter(level)
        proc do |severity, datetime, progname, msg|
          date_format = datetime.strftime("%Y-%m-%d %H:%M:%S.%L")
          extra_logging = ""
          if level == Logger::DEBUG
            # Adjust the '4' as needed based on your call stack
            location = caller_locations(4, 1).first
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
      end
    end

    def logger
      Example::Loggable.logger(@config)
    end

    def die(message)
      logger.error(message)
      exit(1)
    end
  end
end
