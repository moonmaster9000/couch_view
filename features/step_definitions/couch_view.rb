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
