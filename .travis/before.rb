#!/usr/bin/env ruby

puts "running before script..."

cucumber_env = File.read("features/setup/env.rb")

File.open("features/setup/env.rb", "w") do |f| 
  f.write cucumber_env.gsub('admin:password@', '')
end

puts "before script finished!"
