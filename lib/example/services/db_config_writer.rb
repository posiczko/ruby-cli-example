require "dry/monads"
require "fileutils"

require "example/loggable"

# Writes the configured database settings to the XDG-located database.yml,
# creating the directory on the way. Both the CLI (`db initialize`) and the
# `db:config_create` rake task go through here, so the file has one author.
#
# @example
#   Example::Services::DbConfigWriter.call(config) # => Success(#<Pathname .../database.yml>)
class Example::Services::DbConfigWriter
  include Dry::Monads[:result]
  include Example::Loggable

  def self.call(config)
    new(config).call
  end

  def initialize(config)
    @config = config
  end

  # @return [Dry::Monads::Result] the written path, or the failure message
  def call
    path = Example.database_config_path
    logger.info("Creating database config file.")
    FileUtils.mkdir_p(path.dirname)
    File.write(path, Example.database_settings.to_yaml)
    logger.info("Wrote the config file in #{path}.")
    Success(path)
  rescue SystemCallError => e
    Failure("ERROR: Unable to create database config. Error: #{e.message}")
  end
end
