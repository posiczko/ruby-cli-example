require "runcom"

class Example::Services::DbConfig
  def self.call(gem_spec, root_path, debug = false)
    {
      gem_spec: gem_spec,
      root_path: root_path,
      debug: debug,
      module_name: gem_spec.name,
      xdg_database_config: Runcom::Config.new("#{gem_spec.name}/database.yml")
    }
  end
end
