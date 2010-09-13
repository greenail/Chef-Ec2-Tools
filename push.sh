#!/usr/bin/ruby
system("git commit -a -m 'more'")
system("knife cookbook upload #{ARGV[0]} -o /local/chef-repo/cookbooks")

