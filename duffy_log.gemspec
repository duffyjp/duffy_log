$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "duffy_log/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "duffy_log"
  spec.version     = DuffyLog::VERSION
  spec.authors     = ["Jacob Duffy"]
  spec.email       = ["duffy.jp@gmail.com"]
  spec.homepage    = "https://github.com/duffyjp/duffy_log"
  spec.summary     = "Log long running tasks with status."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0"

  spec.add_development_dependency "amazing_print"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3"

end
