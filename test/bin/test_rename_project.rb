require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

# Exercises bin/rename-project against a miniature copy of the project layout
# so the real checkout is never touched.
#
# The placeholder name is read from the script rather than written here: the
# script rewrites every file but itself, so a spelled-out fixture would be
# renamed along with the project and these tests would go red afterwards.
class TestRenameProject < Minitest::Test
  SCRIPT = File.expand_path("../../bin/rename-project", __dir__)
  OLD_NAME = File.read(SCRIPT)[/^\s*OLD_NAME = "(\w+)"/, 1]
  OLD_CONSTANT = File.read(SCRIPT)[/^\s*OLD_CONSTANT = "(\w+)"/, 1]

  def setup
    @root = Pathname(Dir.mktmpdir("rename-project"))
    FileUtils.mkdir_p(@root.join("bin"))
    FileUtils.cp(SCRIPT, @root.join("bin/rename-project"))
    write("lib/#{OLD_NAME}.rb", "module #{OLD_CONSTANT}\n  module CLI\n  end\nend\n")
    write("lib/#{OLD_NAME}/version.rb", "module #{OLD_CONSTANT}\n  GEM_NAME = \"ruby-cli-#{OLD_NAME}\"\nend\n")
    write("exe/#{OLD_NAME}", "require \"#{OLD_NAME}\"\n")
    write("#{OLD_NAME}.gemspec", "spec.name = #{OLD_CONSTANT}::GEM_NAME\n# spec.add_dependency \"#{OLD_NAME}-gem\"\n")
    write("test/test_#{OLD_NAME}.rb", "class Test#{OLD_CONSTANT} < Minitest::Test\nend\n")
    write("README.md", "Run exe/#{OLD_NAME} version. Some #{OLD_NAME}s follow.\n")
    write("vendor/#{OLD_NAME}.rb", "module #{OLD_CONSTANT}\nend\n")
  end

  def teardown
    FileUtils.rm_rf(@root)
  end

  def test_reads_the_placeholder_from_the_script
    refute_nil(OLD_NAME)
    refute_nil(OLD_CONSTANT)
  end

  def test_renames_paths_and_rewrites_contents
    out, err, status = rename("my_test")

    assert(status.success?, err)
    assert_match(/paths renamed/, out)
    assert(@root.join("lib/my_test.rb").exist?)
    assert(@root.join("lib/my_test/version.rb").exist?)
    assert(@root.join("exe/my-test").exist?)
    assert(@root.join("test/test_my_test.rb").exist?)
    assert_equal("module MyTest\n  module CLI\n  end\nend\n", read("lib/my_test.rb"))
    assert_equal("class TestMyTest < Minitest::Test\nend\n", read("test/test_my_test.rb"))
  end

  def test_uses_the_dashed_name_for_the_gem_and_executable
    rename("my_test")

    assert_equal("module MyTest\n  GEM_NAME = \"ruby-cli-my-test\"\nend\n", read("lib/my_test/version.rb"))
    assert_equal("require \"my_test\"\n", read("exe/my-test"))
    assert_equal("Run exe/my-test version. Some #{OLD_NAME}s follow.\n", read("README.md"))
  end

  def test_leaves_scaffolding_placeholders_and_vendored_files_alone
    rename("my_test")

    assert_equal("spec.name = MyTest::GEM_NAME\n# spec.add_dependency \"#{OLD_NAME}-gem\"\n", read("my_test.gemspec"))
    assert_equal("module #{OLD_CONSTANT}\nend\n", read("vendor/#{OLD_NAME}.rb"))
  end

  def test_dry_run_changes_nothing
    out, _, status = rename("--dry-run", "my_test")

    assert(status.success?)
    assert_match(/\(dry run\)/, out)
    assert(@root.join("lib/#{OLD_NAME}.rb").exist?)
    assert_equal("module #{OLD_CONSTANT}\n  module CLI\n  end\nend\n", read("lib/#{OLD_NAME}.rb"))
  end

  def test_rejects_an_invalid_name
    _, err, status = rename("My-Test")

    refute(status.success?)
    assert_match(/invalid name/, err)
  end

  def test_fails_when_there_is_nothing_left_to_rename
    rename("my_test")

    _, err, status = rename("other")

    refute(status.success?)
    assert_match(/already been renamed/, err)
  end

  private

  def rename(*arguments)
    Open3.capture3(RbConfig.ruby, @root.join("bin/rename-project").to_s, *arguments)
  end

  def write(relative, content)
    path = @root.join(relative)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, content)
  end

  def read(relative) = File.read(@root.join(relative))
end
