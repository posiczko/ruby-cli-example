# Cli Example

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

- [Features](#features)
- [Screencasts](#screencasts)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Development](#development)
- [Tests](#tests)
- [[License]()](#license)
- [[Security]()](#security)
- [[Code of Conduct]()](#code-of-conduct)
- [[Contributions]()](#contributions)
- [[Versions]()](#versions)
- [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

## Screencasts

## Requirements

1. [Ruby](https://www.ruby-lang.org)

## Setup

To install _with_ security, run:

    # 💡 Skip this line if you already have the public certificate installed.
    gem cert --add <(curl --compressed --location /gems.pem)
    gem install ruby_example --trust-policy HighSecurity

To install _without_ security, run:

    gem install ruby_example

You can also add the gem directly to your project:

    bundle add ruby_example

Once the gem is installed, you only need to require it:

    require "ruby_example"

## Usage

## Development

To contribute, run:

    git clone
    cd ruby_example
    bin/setup

To rename:

* Globally rename `ruby_example` to `<project_name>` in project.
* Globally rename `RubyExample` to `<ProjectName>` in project.
* Rename `lib/ruby_example` and `lib/ruby_example.rb` to `lib/<project_name>` and 
  `lib/<project_name>.rb`
* Rename `spec/lib/ruby_example_spec.rb` to `spec/lib/<project_name>_spec.rb`.
* Rename `exe/ruby_example` to `exe/<project_name>`.
* Ensure to run `bundle update --bundler` followed by `bundle install`.
* Remove `.git` and reinitialize repo.
* Verify by running `bundle exec exe/<project_name>`
* Verify by running `bin/rake`
* Verify by running `bin/console`
* Verify bu running `bin/guard`

You can also use the IRB console for direct access to all objects:

    bin/console

## Tests

To test, run:

    bin/rake

## [License]()

## [Security]()

## [Code of Conduct]()

## [Contributions]()

## [Versions]()

## Credits

- Built with [Gemsmith](https://alchemists.io/projects/gemsmith).
- Engineered by [Pawel Osiczko](https://tetrapyloctomy.org).