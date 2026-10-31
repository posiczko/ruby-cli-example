require "test_helper"
require "dry/monads"
require "stringio"

class TestCLIDBInitialize < Minitest::Test
  include Dry::Monads[:result]

  def setup
    @output = StringIO.new
    @original_logger = Example::Loggable.logger({})
    Example::Loggable.logger = Logger.new(
      @output,
      level: Logger::INFO,
      formatter: -> (severity, _, _, msg) { "#{severity}: #{msg}\n" }
    )
  end

  def teardown
    Example::Loggable.logger = @original_logger
  end

  def test_passes_the_parsed_options_to_the_initializer
    calls = with_initializer_returning(Success(true)) do
      run_cli("db", "initialize", "--overwrite")
    end

    assert_equal([{debug: false, overwrite: true}], calls)
  end

  def test_logs_success
    with_initializer_returning(Success(true)) { run_cli("db", "initialize") }

    assert_match(/INFO: DB config created, DB created, migrations ran/, @output.string)
  end

  def test_logs_the_failure_message
    with_initializer_returning(Failure("boom")) { run_cli("db", "initialize") }

    assert_match(/ERROR: ERROR: Database not created. boom/, @output.string)
  end

  private

  def run_cli(*arguments)
    capture_io { Dry::CLI.new(Example::CLI).call(arguments: arguments) }
  end

  # Hand-rolled stub for the command's one collaborator: records each config
  # it is called with and returns the given result.
  def with_initializer_returning(result)
    calls = []
    service = Example::Services::DbInitializer
    original = service.method(:call)
    service.define_singleton_method(:call) { |config|
      calls << config
      result
    }
    yield
    calls
  ensure
    service.define_singleton_method(:call, original)
  end
end
