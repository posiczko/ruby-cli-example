require "tmpdir"

# Point runcom at a throwaway XDG tree so no test reads or writes the real
# ~/.config/<gem>/database.yml. Runcom resolves the path lazily, so setting the
# variable before any `global` call is enough.
ENV["XDG_CONFIG_HOME"] = Dir.mktmpdir("example-test-xdg")

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "example"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

# Services log through Example::Loggable; keep that noise out of the test run.
Example::Loggable.logger = Logger.new(IO::NULL, level: Logger::INFO)
