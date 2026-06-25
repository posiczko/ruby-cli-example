require "example/services/db_initializer"
require "example/loggable"

module Example::CLI::DB
  class Initialize < Example::CLI::Base
    include Example::Loggable

    option :overwrite, type: :boolean, default: false, desc: "Overwrite the database"

    def call(**options)
      super
      logger.debug("config: #{@config}")
      @config[:overwrite] = options[:overwrite]
      result = Example::Services::DbInitializer.call(@config)

      if result.success?
        logger.info("DB config created, DB created, migrations ran")
      else
        logger.error("ERROR: Database not created. #{result.failure}")
      end
    end
  end
end
