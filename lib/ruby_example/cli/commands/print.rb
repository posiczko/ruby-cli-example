# frozen_string_literal: true

module RubyExample
  module CLI
    module Commands
      # Print command which prints something.
      class Print < RubyExample::CLI::Commands::Base
        desc "Print something"
        option :reset_kajiger, type: :boolean, default: false, desc: "Reset the kajiger"

        def call(**options)
          super
          logger.debug("#{self.class}##{__method__}: Options: #{options}")
          puts "Printed from print command!"
        end
      end
    end
  end
end
