require "active_record"
require "active_support/core_ext/string/inflections"
require "fileutils"

namespace(:db) do
  namespace(:generate) do
    desc("Generate migration")
    task(:migration) do
      name = ARGV[1] || raise("Specify name: rake db:generate:migration your_migration")
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      # Filename is snake_case, class is CamelCase, so either input style
      # (CreateEmployee or create_employee) yields a migration AR can load.
      # Migrations live under lib/example/db/migrations (relative to this file).
      path = File.expand_path("../../example/db/migrations/#{timestamp}_#{name.underscore}.rb", __dir__)
      migration_class = name.camelize

      FileUtils.mkdir_p(File.dirname(path))
      File.write(
        path,
        <<~RUBY
          class #{migration_class} < ActiveRecord::Migration[8.1]
            def self.up
            end

            def self.down
            end
          end
        RUBY
      )

      puts("Migration #{path} created")
      # stop rake from treating the migration name (ARGV[1]) as another task
      exit
    end
  end
end
