require 'csv'
require 'ipaddr'
require 'json'

Bin_size = 5 #seconds

ip_file = ARGV[0]
sel_file = ARGV[1]
if !sel_file
    abort "Must supply file of ips and selected data on command line."
end

dat_file = "movieData.csv"

ips = File.new(ip_file).to_a.map{|line| line.chomp!}

### Line points
start_time = File.open(sel_file, &:readline)[/^[0-9]*\.[0-9]*/].to_f
counter = start_time
end_time = start_time
rows = []
instant = ([nil]*ips.length).map!{|x| h = {}; h.default = 0; h}

CSV.foreach(sel_file) do |ts,ip_loc,ip_for,dir,proto,len|
    ts = ts.to_f
    if ts < end_time then abort "Error: Out of order timestamps." end
    end_time = ts

    if ts > counter + Bin_size
        frame = []
        ips.each_with_index {|ip, i|
            local = []
            instant[i].each {|for_ip, bytes|
                foreign = {d: for_ip, s: (bytes/Bin_size).round}
            }
            frame << local
        }
        rows << frame
        instant = ([nil]*ips.length).map!{|x| h = {}; h.default = 0; h}
        counter += Bin_size
    end

    if proto.start_with?("HTTP") then proto = "HTTP" end
    key_loc = ips.index(ip_loc)
    key_for = (IPAddr.new(ip_for).to_i & 0xFFFF0000) >> 16
    instant[key_loc][key_for] += len.to_i
end

File.open(dat_file, mode="w"){ |file|
    file.puts JSON.fast_generate({num_loc_ips:ips.length,rows:rows})
}
