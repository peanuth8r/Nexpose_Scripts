#Takes a text file of hostnames and creates a CSV file with headers "asset", "IP", "site" 

require 'highline/import' 
require 'nexpose'  
require 'csv'  
require 'Resolv'
include Nexpose 


filename = ARGV[0]
if filename.nil?
  puts ARGV.to_s
  puts "USAGE: ruby Nexpose_VMP_asset_lookup.rb <text file of hostnames>"
  exit
end
hostnames = []
puts "Processing hosts from  #{filename}:"
File.open(filename).readlines.each do |line|
   hostnames << line.strip
end

default_host = 'nexpose'  
host = ask('Enter hostname for Nexpose console:  ') { |q| q.default = default_host }
default_name = 'nxadmin'
userid = ask('Enter your Nexpose username:  ') { |q| q.default = default_name }
password = ask('Enter your Nexpose password:  ') { |q| q.echo = '*' }

nsc = Connection.new(host, userid, password)  
puts 'Logging into Nexpose'  
nsc.login  
puts 'Logged into Nexpose'  

#create hash map of all assets
all_assets = nsc.assets.reduce({}) do |hash, dev|
  $stderr.puts("Duplicate asset: #{dev.address}") if @debug and hash.member? dev.address 
  hash[dev.address] = dev
  hash
end

sites = nsc.sites.reduce({}) do |hash, site|
  hash[site.id] = site
  hash
end
file = "nexpose_asset_lookup.csv"
 CSV.open(file, 'wb') do |csv|
  csv << ["hostname", "IP", "site"]
 end

csv_data = []
hostnames.each do |hostname|
  csv_row = []
  hostname.downcase!
  csv_row.push(hostname)
  puts hostname
  begin
  ip = Resolv.getaddress hostname
   csv_row.push(ip)
  rescue
    csv_row.push(' ')
    next 
  end
  begin
  site = sites[all_assets[ip].site_id].name 
  puts site
  csv_row.push(site)
  rescue
    csv_row.push(' ')
    next
  end
  csv_data.push(csv_row)
end

CSV.open(file, "a+") do |csv|
     csv_data.each { |row| csv << row}
end




