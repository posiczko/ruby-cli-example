module Example::CLI
  class Version < Example::CLI::Base
    def call(...)
      super
      puts(config[:gem_spec].version)
    end
  end
end
