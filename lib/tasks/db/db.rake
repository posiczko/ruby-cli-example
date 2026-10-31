require "active_record"

# Ensure the gem's lib/ is on the load path so `require "example"` (and the
# library's own load-path-style requires) resolve under bare `rake`, not just
# `bundle exec`.
lib = File.expand_path("../..", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "example"

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
# # note: the database config file is resolved via Example.config (the same
# #       XDG-located database.yml the CLI writes), but you will be prompted
# #       for the database user's password
#
namespace(:db) do
  desc("Write the database config file from Example.config (overwrite=true to replace an existing one)")
  task(:config_create) do
    path = Example.database_config_path
    if File.exist?(path) && !ENV["overwrite"]
      puts("Config already exists at #{path} (pass overwrite=true to replace it).")
    else
      result = Example::Services::DbConfigWriter.call({})
      abort(result.failure) if result.failure?
    end
  end

  desc("Create the database")
  task(:create) do
    ActiveRecord::Base.establish_connection(db_config_admin)
    puts("Creating database #{db_config["database"]} ...")
    ActiveRecord::Base.connection.create_database(db_config["database"])
    puts("Database created.")
  end

  desc("Migrate the database")
  task(:migrate) do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.pool.migration_context.migrate
    Rake::Task["db:schema"].invoke
    puts("Database migrated.")
  end

  desc("Drop the database (prompts for confirmation; set FORCE=1 to skip)")
  task(:drop) do
    database = db_config["database"]
    unless confirm?("Permanently drop database '#{database}'?")
      abort("Aborted; database '#{database}' was not dropped.")
    end

    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.drop_database(database)
    puts("Database deleted.")
  end

  desc("Reset the database")
  task(:reset) do
    with_force do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
    end
  end

  desc("Create a db/schema.rb file that is portable against any DB supported by AR")
  task(:schema) do
    connection = ActiveRecord::Base.establish_connection(db_config)
    require "active_record/schema_dumper"

    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(connection, file)
    end
  end

  desc("Rollback the last migration")
  task(:rollback) do
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.pool.migration_context.rollback(step)

    Rake::Task["db:schema"].invoke
    puts("Database rollback.")
  end
  # ...

  desc("Dumps the database to db/backups/")
  task(:dump) do
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
    dir = backup_directory
    cmd = "/usr/bin/find #{dir} -type f -exec ls -alt {} \\+"
    puts(cmd)
    exec(cmd)
  end

  desc("Restore the database from the backup from db/backups/restore.db")
  task(:restore) do
    pattern = ENV["pattern"]
    if pattern.present?
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
        with_force do
          Rake::Task["db:drop"].invoke
          Rake::Task["db:create"].invoke
        end

        puts(cmd)
        system(cmd)
        puts("")
        puts("Restored from file: #{file} to database #{db_config["database"]}")
        puts("")
      else
        puts("Too many files match the pattern '#{pattern}':")
        puts(" " + files.join("\n "))
        puts("")
        puts("Try a more specific pattern")
        puts("")
      end
    end
  end

  # The application database config, read from the same XDG-located file the
  # CLI manages (Example.config.database_config). Memoized so each task resolves
  # it once.
  def db_config
    @db_config ||= begin
      path = Example.database_config_path
      abort("No database config at #{path}. Run `rake db:config_create` first.") unless File.exist?(path)
      Example.read_database_config
    end
  end

  # Admin connection used to create/drop the database: same config but pointed at
  # the "postgres" maintenance database with a public schema search path.
  def db_config_admin
    @db_config_admin ||= db_config.merge("database" => "postgres", "schema_search_path" => "public")
  end

  # Run a block with FORCE set so nested destructive tasks (e.g. db:drop) skip
  # their confirmation prompt. Restores the previous value afterward so it does
  # not leak to other tasks in the same rake run.
  def with_force
    previous = ENV["FORCE"]
    ENV["FORCE"] = "1"
    yield
  ensure
    ENV["FORCE"] = previous
  end

  # Ask for interactive confirmation before a destructive action. Returns true
  # only on an explicit "y"/"yes" or when FORCE is set. A non-interactive run
  # (EOF/no TTY) returns false, so we never destroy data without a clear yes.
  def confirm?(prompt)
    return true if ENV["FORCE"]

    $stderr.print("#{prompt} [y/N]: ")
    answer = $stdin.gets
    !!answer&.strip&.downcase&.start_with?("y")
  end

  def backup_directory(create: false)
    backup_dir = Pathname(__dir__).join("../../db/backups").expand_path

    if create and !Dir.exist?(backup_dir)
      puts("Creating #{backup_dir} ..")
      FileUtils.mkdir_p(backup_dir)
    end

    backup_dir
  end
end
