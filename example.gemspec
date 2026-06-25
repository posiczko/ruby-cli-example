# frozen_string_literal: true

require_relative "lib/example/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-cli-example"
  spec.version = Example::VERSION
  spec.authors = ["Pawel Osiczko"]
  spec.email = ["p.osiczko@tetrapyloctomy.org"]

  spec.summary = "Ruby CLI example summary."
  spec.description = <<~DESC
    Description of the gem.
  DESC
  spec.homepage = "https://github.com/posiczko/test"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.5"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubyfmtignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency("activerecord", "~> 8.1")
  spec.add_dependency("activesupport", "~> 8.1")
  spec.add_dependency("dry-cli", "~> 1.1")
  spec.add_dependency("dry-logger", "~> 1.2.2")
  spec.add_dependency("dry-configurable", "~> 1.4")
  spec.add_dependency("dry-monads", "~> 1.10")
  spec.add_dependency("pg", "~> 1.6.3")
  spec.add_dependency("runcom")
  spec.add_dependency("zeitwerk")
  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
