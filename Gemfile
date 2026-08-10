# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in example.gemspec
gemspec

group :development do
  gem "annotaterb"
  gem "irb"
  gem "rake", "~> 13.0"
end

group :test do
  gem "minitest", "~> 6.0"
  gem "minitest-reporters", require: false
end

group :security do
  gem "bundler-audit"
end

group :types do
  gem "rbs"
  gem "steep"
end

group :tools do
  gem "amazing_print"
  gem "debug"
end

gem "psych", "~> 5.4.0"
