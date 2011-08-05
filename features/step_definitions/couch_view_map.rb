Given /^the .*$/ do |code|
  eval code
end

When /^I instantiate .*$/ do |code|
  @response = eval code
end

Then /^I should.*$/ do |response|
  @response.strip.gsub(/\n[\ ]*/, "").should == response.strip.gsub(/\n[\ ]*/, "")
end
