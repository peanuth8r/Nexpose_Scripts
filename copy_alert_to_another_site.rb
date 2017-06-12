#!/usr/bin/env ruby  
require 'nexpose'  
require 'highline/import' 
include Nexpose


default_host = 'nexpose'  
host = ask('Enter hostname for Nexpose console:  ') { |q| q.default = default_host }
default_name = 'nxadmin'
userid = ask('Enter your Nexpose username:  ') { |q| q.default = default_name }
password = ask('Enter your Nexpose password:  ') { |q| q.echo = '*' }

nsc = Connection.new(host, userid, password)  
puts 'Logging into Nexpose'  
nsc.login  
puts 'Logged into Nexpose'  
  
sites = nsc.list_sites || []  

puts "\n\n***********Available Sites***********"
puts "*****************(id) name*****************"
sites.each do | site |
  puts "(#{site.id})#{site.name}"
end

#*******************************************************
#CHOOSE SITE
puts "Enter site ID to copy alert from:"
from_site_id = gets.chomp.to_i

puts "Enter site ID to copy alert to:"
to_site_id = gets.chomp.to_i

from_site = Nexpose::Site.load(nsc,from_site_id)
  
puts(" Grabbing alerts from Site ##{from_site_id}.")  
alerts = Nexpose::Site.load(nsc, from_site_id).alerts  

to_site = Nexpose::Site.load(nsc, to_site_id)  
to_site.alerts = alerts  
to_site.save(nsc)  
puts("    Site ##{to_site_id} saved")  
  