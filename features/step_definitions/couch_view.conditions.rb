Given /^a CouchView::Config::Conditions object:$/ do |string|
  eval string
end

When /^I pass those condition modules to the condition config object's .*:$/ do |string|
  eval string
end

When /^I add those conditions to my config with custom names:$/ do |string|
  eval string
end
