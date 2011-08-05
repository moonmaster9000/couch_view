Given /^an Article model with a view .*:$/ do |code|
  eval code
end

When /^I limit the results to \d+:$/ do |code|
  eval code
end

Then /^@new_proxy should be a new proxy object:$/ do |code|
  eval code
end
