require "dry/monads"
require "fileutils"

require "example/loggable"

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
    logger.info("Creating database config file.")
    database_config_file = Example.config.database_config.global
    database_config_dir = File.dirname(Example.config.database_config.global)
    logger.debug("Checking if database_config_dir #{database_config_dir} exists.")
    FileUtils.mkdir_p(database_config_dir) unless File.directory?(database_config_dir)

    db = Example.config.database
    yaml_config = {
      "adapter" => db.adapter,
      "host" => db.host,
      "pool" => db.pool,
      "encoding" => db.encoding,
      "database" => db.name
    }.to_yaml

    logger.debug("yaml_config: #{yaml_config.gsub("\n", ", ")}")
    logger.info("Wrote the config file in #{database_config_file}.")
    File.write(database_config_file, yaml_config, mode: "w")

    Success("Database config created")
  rescue => e
    Failure("ERROR: Unable to create database config. Error: #{e.message}")
  end

  def create_database
    database_config_file = Example.config.database_config.global.to_s
    logger.debug("Connecting to the database using #{database_config_file}")
    database_config = YAML.load_file(database_config_file)
    ActiveRecord::Base.establish_connection(database_config.merge("database" => "postgres"))
    if @config[:overwrite]
      ActiveRecord::Base.connection.drop_database(database_config["database"])
      ActiveRecord::Base.connection.create_database(database_config["database"])
    else
      ActiveRecord::Base.connection.create_database(database_config["database"])
    end

    Success("Successfully created database")
  rescue => e
    Failure("ERROR: Unable to create the database #{database_config["database"]}. Error: #{e.message}")
  end

  def migrate_database
    yield Example::DB::Connection.call(@config)

    migrations_path = Example.config.root_dir.join("example/db/migrations").to_s
    migrator = ActiveRecord::MigrationContext.new(migrations_path)
    migrator.migrate

    Success("Database migration done")
  rescue => e
    Failure("ERROR: Unable to migrate the database: #{e.message}")
  end
end
