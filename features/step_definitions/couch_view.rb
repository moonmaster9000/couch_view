When /^I mix .*:$/ do |code|
  eval code
end

Then /^my model should respond to .*:$/ do |code|
  eval code
end

When /^I create an Article:$/ do |code|
  eval code
end

Then /^`map_by_id!` should return the article$/ do |code|
  eval code
end
