$LOAD_PATH.unshift './lib'

require 'couch_view'
require 'couchrest_model_config'
require 'cucumber/rspec/doubles'

CouchRest::Model::Config.edit do
  database do
    default "http://admin:password@localhost:5984/couch_view_test"
  end
end

Before("@db") do
  CouchRest::Model::Config.default_database.recreate!
end
