# frozen_string_literal: true

ruby file: ".ruby-version"

source "https://rubygems.org"

gemspec

group :code_quality do
  gem "git-lint", "~> 7.0"
  gem "reek", "~> 6.3", require: false
  gem "rubocop-shopify", require: false
end

group :development do
  gem "rake", "~> 13.1"
  gem "rubocop", require: false
  gem "tocer", "~> 17.0"
end

group :test do
  gem "guard-rspec", "~> 4.7", require: false
  gem "rspec", "~> 3.12"
end

group :tools do
  gem "amazing_print", "~> 1.5"
  gem "irb"
  gem "debug", "~> 1.9"
end
