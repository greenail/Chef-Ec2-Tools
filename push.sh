#!/usr/bin/ruby
unless File.exists? ARGV[0]
	system("git add #{ARGV[0]}/*")
end
system("git commit -a -m 'more'")
system("knife cookbook upload #{ARGV[0]} -o /local/chef-repo/cookbooks")

