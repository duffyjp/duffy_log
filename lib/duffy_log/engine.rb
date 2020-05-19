module DuffyLog
  class Engine < ::Rails::Engine


    # Append DFM Auth's migrations to the host application
    # http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end

# Wrapper for task
# * Automatically creates a ProcessLog
# * Captures any errors with stack trace
def logged_task(*args, &block)
  task *args do |task|
    log = ProcessLog.create(key: task.to_s)
    begin
      yield
      log.success!
    rescue StandardError => e
      log.fail!(e)
    end
  end
end