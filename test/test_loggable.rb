require "test_helper"
require "stringio"

class TestLoggable < Minitest::Test
  def setup
    @original_logger = Example::Loggable.logger({})
    @output = StringIO.new
  end

  def teardown
    Example::Loggable.logger = @original_logger
  end

  def test_logs_at_info_level_without_the_debug_flag
    logger = Example::Loggable.logger({debug: false})

    assert_equal(Logger::INFO, logger.level)
  end

  def test_logs_at_debug_level_with_the_debug_flag
    logger = Example::Loggable.logger({debug: true})

    assert_equal(Logger::DEBUG, logger.level)
  end

  def test_reuses_the_logger_while_the_level_is_unchanged
    first = Example::Loggable.logger({debug: false})
    second = Example::Loggable.logger({debug: false})

    assert_same(first, second)
  end

  def test_rebuilds_the_logger_when_the_level_changes
    first = Example::Loggable.logger({debug: false})
    second = Example::Loggable.logger({debug: true})

    refute_same(first, second)
  end

  def test_formats_lines_with_a_single_letter_severity_and_timestamp
    Example::Loggable.logger = nil
    formatter = Example::Loggable.logger({debug: false}).formatter
    logger = Logger.new(@output, formatter: formatter)

    logger.info("hello")

    assert_match(/\A\[I\] \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}: hello\n\z/, @output.string)
  end

  def test_tolerates_a_nil_config
    assert_equal(Logger::INFO, Example::Loggable.logger(nil).level)
  end
end

class TestLoggableDie < Minitest::Test
  def test_cli_commands_can_die
    assert_respond_to(Example::CLI::Version.new, :die)
  end

  def test_services_cannot_die
    refute_respond_to(Example::Services::DbInitializer.new({}), :die)
  end
end
