# The models directory is a separate Zeitwerk root (see lib/example.rb), so the
# models it holds are top-level constants and autoload on first reference —
# requiring them here would load them behind Zeitwerk's back.
module Example::DB::Models
end
