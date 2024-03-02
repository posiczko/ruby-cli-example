# frozen_string_literal: true

require "amazing_print"
require "debug"
require "dotenv"
require "dry/cli"
require "dry/logger"
require "runcom"
require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.inflector.inflect("cli" => "CLI")
  loader.setup
end

# Main namespace.
module RubyExample
  # Main CLI module.
  module CLI
    # Main commands module.
    module Commands
      extend Dry::CLI::Registry

      # Base class for commands.
      class Base < Dry::CLI::Command
        attr_reader :logger, :database_file, :root_path

        option :debug, type: :boolean, default: false, desc: "Enable debugging"

        def initialize
          super
          @logger = nil
        end

        def call(**options)
          Dotenv.load
          level      = options[:debug] ? :debug : :info
          @logger    = Dry.Logger(:stdout, level: level, template: "%{severity}: %{time}:  %{message}")
          @root_path = Pathname.new(__dir__).join("..").expand_path
        end

        def die(message)
          @logger.info(message)
          exit(1)
        end
      end

      autoload :Print, "ruby_example/cli/commands/print"
      register "print", Commands::Print
    end
  end
end
