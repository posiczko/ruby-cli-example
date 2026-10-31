# Example

A small command-line tool, packaged as a Ruby gem, that manages a PostgreSQL
database using ActiveRecord. It is built on [`dry-cli`](https://dry-rb.org/gems/dry-cli/)
for command dispatch, [`dry-monads`](https://dry-rb.org/gems/dry-monads/) for
result handling, and [Zeitwerk](https://github.com/fxn/zeitwerk) for autoloading.

Requires Ruby >= 4.0.6 and a reachable PostgreSQL server. The interpreter is
pinned in `.ruby-version`, which both version managers and CI read.

## Installation

This gem is not published to RubyGems. Install it from a checkout:

```bash
git clone https://github.com/posiczko/test
cd test
bin/setup        # bundle install
```

## Renaming the project

The scaffolded name runs through the namespace, paths, gem name and
executable. To adopt this checkout as your own, rename all of it in one pass
with `bin/rename-project`, passing lowercase words joined by underscores:

```bash
bin/rename-project --dry-run my_test   # preview every change
bin/rename-project my_test             # apply
```

It renames files and directories, then rewrites their contents, using the form
each context calls for:

- underscored (`lib/my_test/`, `require "my_test"`, `test_my_test.rb`) for Ruby
  paths, requires and filenames;
- CamelCase (`MyTest`, `MyTest::CLI`, `TestMyTest`) for modules and classes;
- dashed (`exe/my-test`, `ruby-cli-my-test`) for the executable, the gem name
  and bare mentions in prose.

Vendored, generated and VCS-internal directories (`vendor/`, `tmp/`, `.git/`
and friends), binary files, and the script itself are left untouched. Once
there is nothing left to rename, a second run warns and exits non-zero rather
than reporting success.

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

## Dependencies

Runtime dependencies and their version constraints are declared in
`example.gemspec`; development ones are grouped in the `Gemfile`. Both are
installed by `bin/setup`.

### Runtime

- `dry-cli` (`~> 1.1`) — command registry and option parsing; every command
  subclasses `Example::CLI::Base`.
- `dry-configurable` (`~> 1.4`) — the `Example.config` settings block (gem name
  and version, root directory, database settings).
- `dry-monads` (`~> 1.10`) — `Success`/`Failure` results with `do` notation,
  which is how `Example::Services` short-circuits on failure.
- `zeitwerk` (`~> 2.8`) — autoloads `lib/example`, with the `db` → `DB` and
  `cli` → `CLI` inflections.
- `activerecord` (`~> 8.1`) — models, connection handling and migrations. It
  brings in `activesupport`, whose `underscore`/`camelize` inflections drive
  `rake db:generate:migration`.
- `pg` (`~> 1.6`) — the PostgreSQL adapter ActiveRecord connects through.
- `runcom` (`~> 13.3`) — resolves the XDG location of `database.yml`.

`psych` (`~> 5.4.0`) — the YAML implementation that config is read and written
with — is pinned in the `Gemfile` rather than the gemspec, since it ships with
Ruby and only the pin matters here.

### Development

- `rake` (`~> 13.0`) — task runner for everything under `lib/tasks/`.
- `irb` — backs `bin/console`.
- `annotaterb` — schema annotations for models, wired up in
  `lib/tasks/annotaterb.rake`.
- `minitest` (`~> 6.0`) — test framework, driven by `Minitest::TestTask` in the
  `Rakefile`.
- `minitest-reporters` — richer test output; `test/test_helper.rb` selects the
  spec reporter, which prints one line per test name and result.
- `rbs` and `steep` — the signatures in `sig/` and the `rake types` checks.
- `bundler-audit` — the dependency vulnerability scan behind
  `rake security:audit`, which also runs as its own CI job.
- `amazing_print` and `debug` — the `:tools` group, loaded into `bin/console`
  for pretty-printing and breakpoints.

Development gems without a constraint above are unpinned in the `Gemfile`;
`Gemfile.lock` records what is actually resolved.

### External tools

These are not gems and must be installed separately:

- [rubyfmt](https://github.com/fables-tales/rubyfmt) — formatting, via `rake lint`.
- [gitleaks](https://github.com/gitleaks/gitleaks) — credential scan, via `rake security:secrets`.
- `pg_dump` and `pg_restore` — used by `rake db:dump` and `rake db:restore`.
- [prek](https://github.com/j178/prek) — runs the `.pre-commit-config.yaml` hooks.

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

The suite needs no PostgreSQL: `test/test_helper.rb` points `XDG_CONFIG_HOME` at
a temporary directory, so tests never read or write your real `database.yml`.
To run a single test:

```bash
ruby -Ilib -Itest test/test_example.rb           # one file
ruby -Ilib -Itest test/test_example.rb -n NAME   # one test
```

Code is formatted with [rubyfmt](https://github.com/fables-tales/rubyfmt) and
type-checked with [Steep](https://github.com/soutaro/steep) against RBS
signatures in `sig/`. A [pre-commit](https://pre-commit.com/) configuration
(`.pre-commit-config.yaml`) runs rubyfmt and the security audit.

### Database rake tasks

In addition to the CLI, `lib/tasks/db/` provides Rails-style database tasks.
They read the same XDG-located `database.yml` the CLI manages;
`rake db:config_create` writes it (pass `overwrite=true` to replace one):

```bash
rake db:config_create
rake db:create     rake db:migrate    rake db:drop      rake db:reset
rake db:rollback   rake db:schema     rake db:dump      rake db:restore pattern=...
rake db:seed:all   rake db:generate:migration NAME
```

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
