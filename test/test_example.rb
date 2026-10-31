require "test_helper"
require "open3"

class TestExample < Minitest::Test
  LIB = File.expand_path("../lib", __dir__)

  def test_that_it_has_a_version_number
    refute_nil(::Example::VERSION)
  end

  # Bundler preloads lib/example/version.rb through the gemspec, which hides an
  # entry point that forgets to require it. Undo that preload in a child
  # process (when there is one), then load the gem the way a plain `ruby -Ilib`
  # run would.
  def test_entry_point_loads_the_version_file_itself
    script = <<~RUBY
      if defined?(Example::VERSION)
        Example.send(:remove_const, :VERSION)
        Example.send(:remove_const, :GEM_NAME)
        $LOADED_FEATURES.reject! { |feature| feature.end_with?("example/version.rb") }
      end
      require "example"
      puts(Example.config.gem_name)
    RUBY

    out, err, status = Open3.capture3(RbConfig.ruby, "-I", LIB, "-e", script)

    assert(status.success?, err)
    assert_equal("#{Example::GEM_NAME}\n", out)
  end

  def test_gem_name_is_configured_from_the_constant
    assert_equal(Example::GEM_NAME, Example.config.gem_name)
  end

  def test_gem_version_is_configured_from_the_constant
    assert_equal(Example::VERSION, Example.config.gem_version)
  end

  def test_database_name_is_the_underscored_gem_name
    assert_equal("ruby_cli_example", Example.config.database.name)
  end
end

class TestExampleDatabaseSettings < Minitest::Test
  def test_database_settings_is_the_hash_written_to_database_yml
    expected = {
      "adapter" => "postgresql",
      "host" => "127.0.0.1",
      "pool" => 20,
      "encoding" => "utf-8",
      "database" => "ruby_cli_example"
    }

    assert_equal(expected, Example.database_settings)
  end

  def test_database_config_path_is_the_xdg_located_database_yml
    expected = Pathname(ENV.fetch("XDG_CONFIG_HOME")).join("ruby-cli-example/database.yml")

    assert_equal(expected, Example.database_config_path)
  end

  def test_read_database_config_parses_the_file_at_the_config_path
    path = Example.database_config_path
    FileUtils.mkdir_p(path.dirname)
    File.write(path, {"adapter" => "postgresql", "database" => "from_file"}.to_yaml)

    assert_equal({"adapter" => "postgresql", "database" => "from_file"}, Example.read_database_config)
  ensure
    FileUtils.rm_rf(path.dirname)
  end
end
