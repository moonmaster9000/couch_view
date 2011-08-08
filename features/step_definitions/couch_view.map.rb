Given /^the .*$/ do |code|
  eval code
end

When /^I instantiate .*$/ do |code|
  @response = eval code
end

Then /^I should not be able to call .*$/ do |code|
  eval code
end

Then /^I should receive.*$/ do |response|
  @response.strip.gsub(/\n[\ ]*/, "").should == response.strip.gsub(/\n[\ ]*/, "")
end
