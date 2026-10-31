require "dry/monads"

require "example/loggable"
require "example/services/db_config_writer"

class Example::Services::DbInitializer
  include Dry::Monads[:result, :do]
  include Example::Loggable

  def self.call(config)
    new(config).call
  end

  def initialize(config)
    @config = config
  end

  def call
    yield create_database_config
    yield create_database
    yield migrate_database
    Success(true)
  end

  private

  def create_database_config
    Example::Services::DbConfigWriter.call(@config)
  end

  def create_database
    database_config = Example.read_database_config
    database = database_config["database"]
    ActiveRecord::Base.establish_connection(database_config.merge("database" => "postgres"))
    connection = ActiveRecord::Base.connection
    connection.drop_database(database) if @config[:overwrite]
    connection.create_database(database)

    Success("Successfully created database")
  rescue => e
    Failure("ERROR: Unable to create the database. Error: #{e.message}")
  end

  def migrate_database
    yield Example::DB::Connection.call(@config)

    migrations_path = Example.config.root_dir.join("#{Example.config.module_name}/db/migrations").to_s
    migrator = ActiveRecord::MigrationContext.new(migrations_path)
    migrator.migrate

    Success("Database migration done")
  rescue => e
    Failure("ERROR: Unable to migrate the database: #{e.message}")
  end
end
