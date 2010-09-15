#!/usr/bin/ruby
require 'json'

json = `knife client list`
client_list = JSON.parse(json)
puts client_list
#ec2_list = `knife ec2 server list|awk '{print $1 " " $7}'`
list = `knife ec2 server list`
list = list.to_a[2..-1].join
ec2_list = []
for l in list
	l.chop!
	a = l.split()
	puts a[0],a.last()
	ec2_list << [a[0],a.last()]
end
#puts "\nEC2_list"
#puts ec2_list

puts "\nParsing..."
running = []
stopped = []
stopping = []
terminated = []
for a in ec2_list
	id, state = a
	puts "Instance ID: #{id} Ec2 State: #{state}"
	if client_list.grep(id)
		if state == "running"
			running << id
		elsif state == "shutting-down"
			stopping << id
		elsif state == "terminated"
			terminated << id
		else
			stopped << id
		end
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
	system("knife ec2 server delete #{i}")
end
