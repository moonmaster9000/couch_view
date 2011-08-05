Gem::Specification.new do |s|
  s.name        = "couch_view"
  s.version     = File.read "VERSION"
  s.authors     = "Matt Parker"
  s.summary     = "Powerful views for CouchRest::Model::Base"
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["features/**/*"]

  s.add_dependency "couchrest_model", "~> 1.0.0"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "rspec"
end
