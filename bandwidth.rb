require 'csv'
require 'date'
require 'json'

binSize = 3

begin
    ppFile = ARGV[0]
    pcapRange = ppFile.match(/[0-9]*-[0-9]*/)[0]
rescue
    abort "Must supply preprocessed file on command line."
end

dat_file = "bandwidth."+pcapRange+".csv"

class Timestamped
# Representes a comparable value with auxillary timestamp data
    include Comparable

    def initialize(val, ts)
        @val = val
        @ts = ts
    end

    attr_accessor :val, :ts

    def <=> (other)
        @val <=> other.val
    end

end

class Bandwidth
# Represents up and dn Timestamped bandwidths
    def initialize(up, dn)
        @up = up
        @dn = dn
    end

    attr_accessor :up, :dn

    def merge(up, dn)
        Bandwidth.new([@up, up].max, [@dn, dn].max)
    end

end

start_time = File.open(ppFile, &:readline)[/^[0-9]*/]
last_break = -1
highest_bwidths = Hash.new
highest_bwidths.default = Bandwidth.new(Timestamped.new(0,-1), Timestamped.new(0,-1))
up_h = Hash.new
up_h.default = 0
dn_h = Hash.new
dn_h.default = 0

CSV.foreach(ppFile) do |ut,cap,ip,dir,cnt|
    ts = Time.at(ut.to_i)

    if ts.sec % binSize == 0 && last_break != ts.sec
        last_break = ts.sec
        keys = (up_h.keys.concat(dn_h.keys)).uniq!
        keys.each {|key|
            up = Timestamped.new(up_h[key]/binSize, ut)
            dn = Timestamped.new(dn_h[key]/binSize, ut)
            highest_bwidths[key] = highest_bwidths[key].merge(up, dn)
        }
        up_h.clear
        dn_h.clear
    end

    if dir == "up"
        up_h[ip] += cnt.to_i
    else
        dn_h[ip] += cnt.to_i
    end
end


file = File.open(dat_file, mode="w"){ |file|
    file.puts "ip,up,upt,dn,dnt"
    highest_bwidths.each { |key, val|
        file.puts [key, val.up.val, val.up.ts, val.dn.val, val.dn.ts].join(",")
    }
}
