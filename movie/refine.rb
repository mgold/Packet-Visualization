require 'csv'
require 'ipaddr'
require 'json'

Bin_size = 5 #seconds

ip_file = ARGV[0]
sel_file = ARGV[1]
if !sel_file
    abort "Must supply file of ips and selected data on command line."
end

dat_file = "movieData.json"

ips = File.new(ip_file).to_a.map{|line| line.chomp!}

class LocalIP
    def initialize()
        @h = Hash.new{ |h,k| h[k] = Hash.new(0) }
    end

    def clear()
        @h = Hash.new{ |h,k| h[k] = Hash.new(0) }
    end

    def addPacket(foreign_code, proto, size, dir)
        @h[foreign_code][[proto,dir]] += size
    end

    def local(bin_size)
        ret = []
        @h.each{|foreign_code, h2|
            best_bytes = 0;
            best_proto = ""
            best_dir = ""
            h2.each{|key, bytes|
                if bytes > best_bytes
                    best_bytes = bytes
                    best_proto = key[0]
                    best_dir   = key[1]
                end
            }
            if best_bytes > 0
                ret << {f: foreign_code, p: best_proto,
                        s: (best_bytes/bin_size).round, d: best_dir}
            end
        }
        ret
    end

end

### Line points
start_time = File.open(sel_file, &:readline)[/^[0-9]*\.[0-9]*/].to_f
counter = start_time
end_time = start_time
rows = []
instant = ([nil]*ips.length).map!{|x| LocalIP.new}

CSV.foreach(sel_file) do |ts,ip_loc,ip_for,dir,proto,len|
    ts = ts.to_f
    if ts < end_time then abort "Error: Out of order timestamps." end
    end_time = ts

    if ts > counter + Bin_size
        frame = []
        instant.each {|obj|
            frame << obj.local(Bin_size)
        }
        rows << frame
        instant.map{|obj| obj.clear}
        counter += Bin_size
    end

    key_loc = ips.index(ip_loc)
    key_for = (IPAddr.new(ip_for).to_i & 0xFFFF0000) >> 16
    instant[key_loc].addPacket(key_for, proto[0], len.to_i, dir[0])
end

File.open(dat_file, mode="w"){ |file|
    file.puts JSON.fast_generate(rows)
}
