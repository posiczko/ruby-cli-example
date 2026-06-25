require "active_record"
require "dry/monads"
require "yaml"

class Example::DB::Connection
  include Dry::Monads[:result]
  include Example::Loggable

  def self.call(config)
    new(config).call
  end

  def initialize(config)
    @config = config
  end

  def call
    database_config_file = @config[:xdg_database_config].global.to_s
    logger.debug("Connecting to the database using #{database_config_file}")
    database_config = YAML.load_file(database_config_file)
    ActiveRecord::Base.establish_connection(database_config)
    Success(database_config)
  rescue => e
    Failure("Exception when connecting to the database: #{e.message}")
  end
end
