require 'csv'
require 'json'

RESOLUTION = 0.05 # 1 / number of samples per logarithmic decade

begin
    bFile = ARGV[0]
    pcapRange = bFile[/[0-9]*-[0-9]*/]
    bitmask = bFile[/s(16|24|32)/]
rescue
    abort "Must supply bandwidth file on command line."
end

dat_file = "binband."+pcapRange+"."+bitmask+".json"

up_h = Hash.new
up_h.default = 0
dn_h = Hash.new
dn_h.default = 0

def bin bw
    key = 1.0
    while(bw > 10**key)
        key += RESOLUTION
    end
    #return '%.2f' % 10**key
    return (10**key).round(2)
end

CSV.foreach(bFile) do |ip,up,upt,dn,dnt|
    if ip == "ip" then next end
    if up != "0" then up_h[bin(up.to_i)] += 1 end
    if dn != "0" then dn_h[bin(dn.to_i)] += 1 end
end

file = File.open(dat_file, mode="w"){ |file|
    file.puts JSON.fast_generate(
        { up: up_h.to_a.sort!,
          dn: dn_h.to_a.sort!,
          max: [up_h.max_by{|k,v| v}[1], dn_h.max_by{|k,v| v}[1]].max,
          rez: RESOLUTION
        })
}
