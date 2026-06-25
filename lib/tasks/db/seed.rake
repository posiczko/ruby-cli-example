namespace(:db) do
  desc("Seed the database")
  namespace(:seed) do
    ROOT_DIR = `pwd`.chomp
    Dir["#{ROOT_DIR}/db/seeds/*.rb"].each do |filename|
      ActiveRecord::Base.establish_connection(db_config)
      task_name = File.basename(filename, ".rb")
      desc("Run #{task_name}")
      task(task_name.to_sym) do
        puts("Seeding from #{filename}...")
        load(filename) if File.exist?(filename)
      end
    end

    task(:all) do
      load("#{ROOT_DIR}/db/seed.rb")
    end
  end
end
