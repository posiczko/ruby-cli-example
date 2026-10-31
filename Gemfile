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
  gem "rdoc", "~> 7.0.4"
  gem "debug"
end

# The YAML implementation database.yml is read and written with. It ships with
# Ruby, so the pin lives here rather than in the gemspec.
gem "psych", "~> 5.5"
