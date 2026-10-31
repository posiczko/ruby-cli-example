require "active_record"
require "dry/monads"

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
    logger.debug("Connecting to the database using #{Example.database_config_path}")
    database_config = Example.read_database_config
    ActiveRecord::Base.establish_connection(database_config)
    Success(database_config)
  rescue => e
    Failure("Exception when connecting to the database: #{e.message}")
  end
end
