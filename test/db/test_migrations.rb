require "test_helper"
require "active_record"

class TestMigrations < Minitest::Test
  MIGRATIONS_PATH = Example.config.root_dir.join("#{Example.config.module_name}/db/migrations")

  def test_ships_a_migration_creating_the_employees_table
    files = Dir[MIGRATIONS_PATH.join("[0-9]*_*.rb").to_s]

    assert_equal(["create_employees"], files.map { |file| File.basename(file, ".rb").sub(/\A\d+_/, "") })
  end

  def test_the_migration_loads_as_an_active_record_migration
    load(Dir[MIGRATIONS_PATH.join("*_create_employees.rb").to_s].fetch(0))

    assert_operator(CreateEmployees, :<, ActiveRecord::Migration)
  end
end
