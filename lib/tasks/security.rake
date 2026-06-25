require "bundler/audit/task"

Bundler::Audit::Task.new

namespace :security do
  desc "Scan the working tree for committed credential leaks (gitleaks)"
  task :secrets do
    sh "gitleaks dir . --config .gitleaks.toml --redact"
  end

  desc "Update vulnerability database and run audit (bundler-audit + gitleaks)"
  task :audit do
    Rake::Task["bundle:audit:update"].invoke
    Rake::Task["bundle:audit"].invoke
    Rake::Task["security:secrets"].invoke
  end
end