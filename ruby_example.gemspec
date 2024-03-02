# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "ruby_example"
  spec.version = "0.0.0"
  spec.authors = ["Pawel Osiczko"]
  spec.email = ["p.osiczko@tetrapyloctomy.org"]
  spec.homepage = ""
  spec.summary = ""
  spec.license = "MIT"

  spec.metadata = { "label" => "Cli Example", "rubygems_mfa_required" => "true" }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.3"
  spec.add_dependency("dotenv")
  spec.add_dependency("dry-cli", "~> 1.0")
  spec.add_dependency("dry-logger")
  spec.add_dependency("refinements", "~> 12.0")
  spec.add_dependency("runcom", "~> 11.0")
  spec.add_dependency("zeitwerk", "~> 2.6")

  spec.bindir = "exe"
  spec.executables << "ruby_example"
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
