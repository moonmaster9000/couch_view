Given /^an Article model that maps ByLabel:$/ do |code|
  eval code
end

Given /^several articles:$/ do |code|
  eval code
end

When /^I set the CouchDB.*query option to.*:$/ do |code|
  eval code
end

Then /^.* should raise an exception:$/ do |code|
  eval code
end

Then /^.* should not raise an exception:$/ do |code|
  eval code
end

Given /^there are .*articles:$/ do |code|
  eval code
end
