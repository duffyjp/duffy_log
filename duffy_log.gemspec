$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "duffy_log/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "duffy_log"
  spec.version     = DuffyLog::VERSION
  spec.authors     = ["Jacob Duffy"]
  spec.email       = ["duffy.jp@gmail.com"]
#  spec.homepage    = "TODO"
  spec.summary     = "ProcessLog MVC"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0"

  spec.add_development_dependency "amazing_print"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"

end
