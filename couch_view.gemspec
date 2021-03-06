Gem::Specification.new do |s|
  s.name        = "couch_view"
  s.version     = File.read "VERSION"
  s.authors     = "Matt Parker"
  s.homepage    = "http://github.com/moonmaster9000/couch_view"
  s.email       = "moonmaster9000@gmail.com"
  s.description = "Modular, de-coupled views for CouchDB."
  s.summary     = "Powerful views for CouchRest::Model::Base"
  s.files       = Dir["lib/**/*"] << "readme.markdown"
  s.test_files  = Dir["features/**/*"]

  s.add_dependency "couchrest", "1.0.1"
  s.add_dependency "couchrest_model", "~> 1.0.0"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "rspec"
  s.add_development_dependency "couchrest_model_config"
end
