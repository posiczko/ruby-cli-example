# frozen_string_literal: true

ruby file: ".ruby-version"

source "https://rubygems.org"

gemspec

group :code_quality do
  gem "git-lint"
  gem "reek", require: false
  gem "rubocop-shopify", require: false
  gem "simplecov", require: false
end

group :development do
  gem "rake"
  gem "rubocop", require: false
  gem "tocer"
end

group :test do
  gem "guard-rspec", require: false
  gem "rspec"
end

group :tools do
  gem "amazing_print"
  gem "irb"
  gem "debug"
end
