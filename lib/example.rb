# frozen_string_literal: true

require "dry/cli"
require "dry/configurable"
require "pathname"
require "runcom"
require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.inflector.inflect("db" => "DB")
  loader.inflector.inflect("cli" => "CLI")
  loader.tag = File.basename(__FILE__, ".rb")
  loader.push_dir(__dir__)
  loader.setup
end

# Open the top-level namespace before the explicit requires below. Those files
# reopen Example::* and need the Example constant to already exist. Zeitwerk maps
# Example to this very file, so it can't autoload the constant while this file is
# still mid-load — we must define it ourselves first.
module Example
  extend Dry::Configurable

  setting :gem_name, default: "example"
  setting :gem_version, default: "0.0.0"
  setting :root_dir, constructor: -> (value) { Pathname(value) }
  setting :database_config, constructor: -> (name) { Runcom::Config.new("#{name}/database.yml") }

  setting :database do
    setting :adapter, default: "postgresql"
    setting :host, default: "127.0.0.1"
    setting :pool, default: 20
    setting :encoding, default: "utf-8"
    setting :name, constructor: -> (value) { value.to_s.tr("-", "_") }
  end
end

require "example/services"
require "example/db/connection"
require "example/db/models"

ROOT_DIR = Pathname.new(__dir__).expand_path unless defined?(ROOT_DIR)
GEM_SPEC = Gem::Specification.load("example.gemspec")

module Example
  module CLI
    extend Dry::CLI::Registry

    class Base < Dry::CLI::Command
      include Example::Loggable

      attr_reader :config

      option :debug, type: :boolean, default: false, desc: "Enable debugging"

      def call(**options)
        @config = options
      end

      def die(message)
        @logger.info(message)
        exit(1)
      end
    end

    register "version", Version

    register "db", aliases: ["g"] do |prefix|
      prefix.register "initialize", DB::Initialize
    end
  end
end

Example.configure do |config|
  config.gem_name = GEM_SPEC.name
  config.gem_version = GEM_SPEC.version
  config.root_dir = ROOT_DIR
  # constructor coerces -> "ruby_cli_example"
  config.database.name = GEM_SPEC.name
  config.database_config = GEM_SPEC.name
end
