# frozen_string_literal: true

require "dry/logger"

# Loggable module.
module RubyExample::Loggable
  def logger
    level   = @options[:debug] ? :debug : :info
    @logger ||= Dry.Logger(:stdout, level: level, template: "%{severity}: %{time}:  %{message}")
  end

  def die(message)
    logger.error(message)
    exit(1)
  end
end
