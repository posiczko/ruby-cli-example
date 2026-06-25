module Example::CLI
  class Version < Example::CLI::Base
    def call(...)
      super
      puts(Example.config.gem_version)
    end
  end
end
