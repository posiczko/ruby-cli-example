require "active_record"

# Usage:
#
# # dump the development db
# rake db:dump
#
# # dump the db in a specific format
# rake db:dump format=sql
#
# # dump a table (e.g. users table)
# rake db:dump:table table=users
#
# # dump a table in a specific format
# rake db:dump:table table=users format=sql
#
# # list dumps
# rake db:dumps
#
# # dump the production db
# RAILS_ENV=production rake db:dump
#
# # restore db based on a backup file pattern (e.g. timestamp)
# rake db:restore pattern=20170101
#
# # note: config/database.yml is used for database configuration,
# #       but you will be prompted for the database user's password
#
namespace(:db) do
  desc("Create the database")
  task(:create) do
    setup_config
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.create_database(db_config["database"])
    puts("Database created.")
  end

  desc("Migrate the database")
  task(:migrate) do
    setup_config
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.pool.migration_context.migrate
    Rake::Task["db:schema"].invoke
    puts("Database migrated.")
  end

  desc("Drop the database")
  task(:drop) do
    setup_config
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.drop_database(db_config["database"])
    puts("Database deleted.")
  end

  desc("Reset the database")
  task(reset: [:drop, :create, :migrate])

  desc("Create a db/schema.rb file that is portable against any DB supported by AR")
  task(:schema) do
    setup_config
    connection = ActiveRecord::Base.establish_connection(db_config)
    require "active_record/schema_dumper"

    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(connection, file)
    end
  end

  desc("Rollback the last migration")
  task(:rollback) do
    setup_config
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.pool.migration_context.rollback(step)

    Rake::Task["db:schema"].invoke
    puts("Database rollback.")
  end
  # ...

  desc("Dumps the database to db/backups/")
  task(:dump) do
    setup_config
    timestamp = Time.now.strftime("%Y-%m-%d-%H-%M")
    dump_file = "db/backups/#{db_config["database"]}_#{timestamp}.backups"
    cmd = <<~HEREDOC
      pg_dump \
        --verbose \
        --clean \
        --no-owner \
        --no-acl \
        --format=c \
        --host #{db_config["host"]} \
        #{db_config["database"]} \
        > #{dump_file}
    HEREDOC
    puts(cmd)
    system(cmd)
    puts("\nDumped to file: #{dump_file}\n")
  end

  desc("Show the existing database backups")
  task(:list_dumps) do
    setup_config
    dir = backup_directory
    cmd = "/usr/bin/find #{dir} -type f -exec ls -alt {} \\+"
    puts(cmd)
    exec(cmd)
  end

  desc("Restore the database from the backup from db/backups/restore.db")
  task(:restore) do
    setup_config
    pattern = ENV["pattern"]
    if pattern.present?
      file = nil
      cmd = nil
      backup_dir = backup_directory
      puts("Backup dir: #{backup_dir}")
      files = Dir.glob("#{backup_dir}/**/*#{pattern}*")
      case files.size
      when 0
        puts("No backups found for the pattern '#{pattern}'")
      when 1
        file = files.first
        cmd = <<~HEREDOC
          pg_restore \
            --verbose \
            --no-owner \
            --no-acl \
            --host=#{db_config["host"]} \
            --dbname=#{db_config["database"]} \
            #{file}
        HEREDOC
        unless cmd.nil?
          Rake::Task["db:drop"].invoke
          Rake::Task["db:create"].invoke
          puts(cmd)
          system(cmd)
          puts("")
          puts("Restored from file: #{file} to database #{db_config["database"]}")
          puts("")
        end
      else
        puts("Too many files match the pattern '#{pattern}':")
        puts(" " + files.join("\n "))
        puts("")
        puts("Try a more specific pattern")
        puts("")
      end
    end
  end

  def setup_config
    db_config = YAML.load_file(Pathname("~/.config/tp-ruby-cli-example/database.yml").expand_path)
    db_config_admin = db_config.merge({"database" => "postgres", "schema_search_path" => "public"})
  end

  def backup_directory(suffix = nil, create: false)
    backup_dir = Pathname(__dir__).join("../../db/backups").expand_path

    if create and !Dir.exist?(backup_dir)
      puts("Creating #{backup_dir} ..")
      FileUtils.mkdir_p(backup_dir)
    end

    backup_dir
  end
end
