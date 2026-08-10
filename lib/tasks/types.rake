# The stdlib signatures rbs must load, read from the Steepfile so the two
# cannot drift: a `library` added there for Steep is picked up here too.
def steep_libraries
  File.readlines("Steepfile").filter_map { |line| line[/^\s*library\s+"([^"]+)"/, 1] }
end

namespace :types do
  desc "Validate RBS syntax in sig/ (catches sigs that reference nonexistent types)"
  task :validate do
    requires = steep_libraries.flat_map { |library| ["-r", library] }
    sh("bundle", "exec", "rbs", *requires, "-I", "sig", "validate")
  end

  desc "Type-check lib/ against sig/ with Steep (catches sig drift from code)"
  task :check do
    sh "bundle exec steep check"
  end
end

desc "Validate RBS sigs and type-check the implementation"
task types: ["types:validate", "types:check"]