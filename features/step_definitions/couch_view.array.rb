Given /^an array of 3 elements:$/ do |code|
  eval code
end

Then /^I should receive all of the subsets of my array:$/ do |code|
  eval code
end
