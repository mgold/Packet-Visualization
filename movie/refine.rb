require 'csv'
require 'ipaddr'

ip_file = ARGV[0]
sel_file = ARGV[1]
if !sel_file
    abort "Must supply file of ips and selected data on command line."
end

dat_file = "movieData.csv"

ips = File.new(ip_file).to_a.map{|line| line.chomp!}

file = File.open(dat_file, mode="w")
file.puts "ts,loc_id,ip_for,dir,proto,len"

CSV.foreach(sel_file) do |ts,ip_loc,ip_for,dir,proto,len|
    ip_for_key = (IPAddr.new(ip_for).to_i & 0xFFFF0000) >> 16
    if proto.start_with?("HTTP") then proto = "HTTP" end
    file.puts [ts,ips.index(ip_loc),ip_for_key,dir[0],proto,len].join(",")
end
