# Example

A small command-line tool, packaged as a Ruby gem, that manages a PostgreSQL
database using ActiveRecord. It is built on [`dry-cli`](https://dry-rb.org/gems/dry-cli/)
for command dispatch, [`dry-monads`](https://dry-rb.org/gems/dry-monads/) for
result handling, and [Zeitwerk](https://github.com/fxn/zeitwerk) for autoloading.

Requires Ruby >= 4.0.5 and a reachable PostgreSQL server.

## Installation

This gem is not published to RubyGems. Install it from a checkout:

```bash
git clone https://github.com/posiczko/test
cd test
bin/setup        # bundle install
```

## Usage

The executable is `exe/example`:

```bash
exe/example version                       # print the gem version
exe/example db initialize                 # write the db config, create the database, run migrations
exe/example db initialize --overwrite     # drop and recreate the database first
```

Global options:

- `--debug` — enable debug-level logging (available on every command).

The `db initialize` command writes a PostgreSQL configuration to an
XDG-located `database.yml` (resolved via [`runcom`](https://github.com/bkuhlmann/runcom),
e.g. `~/.config/example/database.yml`), creates the database, and runs the
migrations found under `lib/example/db/migrations`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Common
tasks (see `Rakefile` and `lib/tasks/`):

```bash
rake                       # default: test + lint + types
rake test                  # run the Minitest suite
rake lint                  # check formatting with rubyfmt
rake lint:all:autocorrect  # auto-format with rubyfmt
rake types                 # validate RBS sigs and type-check with Steep
rake security:audit        # bundler-audit dependency scan
bin/console                # IRB session with the gem loaded
```

To run a single test:

```bash
ruby -Ilib -Itest test/ruby/cli/test_example.rb           # one file
ruby -Ilib -Itest test/ruby/cli/test_example.rb -n NAME   # one test
```

Code is formatted with [rubyfmt](https://github.com/fables-tales/rubyfmt) and
type-checked with [Steep](https://github.com/soutaro/steep) against RBS
signatures in `sig/`. A [pre-commit](https://pre-commit.com/) configuration
(`.pre-commit-config.yaml`) runs rubyfmt and the security audit.

### Database rake tasks

In addition to the CLI, `lib/tasks/db/` provides Rails-style database tasks that
read `config/database.yml`:

```bash
rake db:create     rake db:migrate    rake db:drop      rake db:reset
rake db:rollback   rake db:schema     rake db:dump      rake db:restore pattern=...
rake db:seed:all   rake db:generate:migration NAME
```

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
