Given /^an empty class Map that includes CouchView::Map:$/ do |code|
  eval code
end

When /^I execute:$/ do |code|
  @response = eval code
end

Then /^I should get:$/ do |response|
  @response.strip.gsub(/\n[\ ]*/, "").should == response.strip.gsub(/\n[\ ]*/, "")
end

Given /^an Article model$/ do
  class Article < CouchRest::Model::Base; end
end

Given /^a ByLabel model in which I define my own map:$/ do |code|
  eval code
end
