#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'optiflag'

 module DBChecker extend OptiFlagSet
   #flag "role"
   optional_switch_flag "dry"
   optional_switch_flag "yes"

   and_process!
 end
dry = ARGV.flags.dry
json = `knife client list`
client_list = JSON.parse(json)
#puts client_list
#ec2_list = `knife ec2 server list|awk '{print $1 " " $7}'`
list = `knife ec2 server list`
list = list.to_a[2..-1].join
ec2_list = {}
for l in list
	l.chop!
	a = l.split()
	#puts a[0],a.last()
	ec2_list[a[0]] = a.last()
end
#puts "\nEC2_list"
#puts ec2_list

# add non-interactive mode if yes flag is active

knife_args = ""
knife_args = "-y" if yes


puts "\nParsing..."
running = []
stopped = []
stopping = []
terminated = []
unknown = []
not_found = []
for id in client_list
	next unless id =~ /^i-/
	#puts "Instance ID: #{id}"
	if ec2_list.has_key?(id)
		state = ec2_list[id]
		if state == "running"
			running << id
		elsif state == "shutting-down"
			stopping << id
		elsif state == "terminated"
			terminated << id
		elsif state == "stopped"
			stopped << id
		else
			unknown << id
		end
	else
		not_found << id
		#print "#"
	end
end

puts "\nStopped Instances: #{stopped.count} out of #{client_list.count} Chef clients"
puts "\nRunning Instances: #{running.count} out of #{client_list.count} Chef clients"
for i in running
	puts "\t#{i}"
end
puts "\nTerminated Instances: #{terminated.count} out of #{client_list.count} Chef clients"
for i in terminated
	puts "\t#{i}"
	system("knife client delete #{i} #{knife_args}") unless dry
end
puts "\nNot Found Instances: #{not_found.count} out of #{client_list.count} Chef clients"
for i in not_found
        puts "\t#{i}"
        system("knife client delete #{i} #{knife_args}") unless dry
end
puts "\nUnknown Instances: #{unknown.count} out of #{client_list.count} Chef clients"
