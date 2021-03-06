When /^I mix .*:$/ do |code|
  eval code
end

Then /^my model should respond to .*:$/ do |code|
  eval code
end

When /^I create an Article:$/ do |code|
  eval code
end

Then /^`.*` should return the article$/ do |code|
  eval code
end

Then /^my proxy should map .*$/ do |code|
  eval code
end

Then /^I should receive a.*proxy:$/ do |code|
  eval code
end

When /^I create.*articles:$/ do |code|
  eval code
end

Then /^`count_by_id!` should return .*:$/ do |code|
  eval code
end

When /^I pass :label to the `map` class method:$/ do |code|
  eval code
end

When /^I create some articles with labels:$/ do |code|
  eval code
end

Then /^they should be indexed in my label map:$/ do |code|
  eval code
end

When /^I add them as conditions to a map over my model's label property:$/ do |code|
  eval code
end

When /^I create visible and published documents:$/ do |code|
  eval code
end

Then /^I should be able to query them through my query proxy:$/ do |code|
  eval code
end

Given /^a.*model:$/ do |code|
  eval code
end

When /^I define a map over labels with a custom reduce that always returns .*:$/ do |code|
  eval code
end

When /^I create two articles with the same label:$/ do |code|
  eval code
end

Then /^`reduce_by_label` should return.*:$/ do |code|
  eval code
end

When /^I call.*with.*:$/ do |code|
  eval code
end

Then /^my model should not respond to .*:$/ do |code|
  eval code
end

When /^I create two articles with labels:$/ do |code|
  eval code
end

Then /^".*" should return.*:$/ do |code|
  eval code
end

When /^I define a map over labels that includes a published condition:$/ do |code|
  eval code
end

Then /^Article should respond to ".*":$/ do |code|
  eval code
end

When /^I update the map over label definition with a visible condition:$/ do |code|
  eval code
end
