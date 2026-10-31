require "test_helper"

class TestDbConfigWriter < Minitest::Test
  def setup
    @path = Example.database_config_path
    FileUtils.rm_rf(@path.dirname)
  end

  def teardown
    FileUtils.rm_rf(@path.dirname)
  end

  def test_writes_the_database_settings_as_yaml
    result = Example::Services::DbConfigWriter.call({})

    assert(result.success?, result.inspect)
    assert_equal(Example.database_settings, YAML.load_file(@path))
  end

  def test_creates_missing_parent_directories
    refute(@path.dirname.exist?)

    Example::Services::DbConfigWriter.call({})

    assert(@path.exist?)
  end

  def test_returns_the_written_path_on_success
    result = Example::Services::DbConfigWriter.call({})

    assert_equal(@path, result.value!)
  end

  def test_fails_when_the_config_directory_cannot_be_created
    FileUtils.mkdir_p(@path.dirname.dirname)
    File.write(@path.dirname, "a file where the directory should be")

    result = Example::Services::DbConfigWriter.call({})

    assert(result.failure?)
    assert_match(/Unable to create database config/, result.failure)
  end
end
