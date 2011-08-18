When /^I (?:create a |change the).*:$/ do |code|
  eval code
end

When /^I add the Published and Visible conditions to it:$/ do |code|
  eval code
end

When /^I give it a base name of .*:$/ do |code|
  eval code
end

Then /^adding the same condition multiple times will result in the condition only being added once:$/ do |code|
  eval code
end
