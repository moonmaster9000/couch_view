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
