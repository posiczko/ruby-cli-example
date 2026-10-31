require "example/services/db_initializer"

module Example::CLI::DB
  class Initialize < Example::CLI::Base
    option :overwrite, type: :boolean, default: false, desc: "Overwrite the database"

    def call(**options)
      super
      logger.debug("config: #{@config}")
      result = Example::Services::DbInitializer.call(@config)

      if result.success?
        logger.info("DB config created, DB created, migrations ran")
      else
        logger.error("ERROR: Database not created. #{result.failure}")
      end
    end
  end
end
