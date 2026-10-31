require "test_helper"
require "open3"
require "tmpdir"

class TestCLIVersion < Minitest::Test
  EXECUTABLE = File.expand_path("../../exe/example", __dir__)

  def test_prints_the_version
    out, err = capture_io { Dry::CLI.new(Example::CLI).call(arguments: ["version"]) }

    assert_equal("#{Example::VERSION}\n", out)
    assert_empty(err)
  end

  def test_runs_from_any_working_directory
    Dir.mktmpdir do |dir|
      out, err, status = Open3.capture3(RbConfig.ruby, EXECUTABLE, "version", chdir: dir)

      assert(status.success?, err)
      assert_equal("#{Example::VERSION}\n", out)
    end
  end
end
