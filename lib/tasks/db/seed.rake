namespace(:db) do
  desc("Seed the database")
  namespace(:seed) do
    # Project root, resolved relative to this file (lib/tasks/db) so it's correct
    # regardless of the working directory. A local — not a reassignment of the
    # gem's ROOT_DIR constant.
    project_root = File.expand_path("../../..", __dir__)

    Dir["#{project_root}/db/seeds/*.rb"].each do |filename|
      task_name = File.basename(filename, ".rb")
      desc("Run #{task_name}")
      task(task_name.to_sym) do
        ActiveRecord::Base.establish_connection(db_config)
        puts("Seeding from #{filename}...")
        load(filename) if File.exist?(filename)
      end
    end

    task(:all) do
      ActiveRecord::Base.establish_connection(db_config)
      load("#{project_root}/db/seed.rb")
    end
  end
end
