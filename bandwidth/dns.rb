require 'csv'
require 'resolv'
require 'json'

begin
    bFile = ARGV[0]
rescue
    abort "Must supply bandwidth file on command line."
end

if ! bFile["s32"] then
    abort "Must supply s32 file."
end

dat_file = "data/reverse_dns.json"

dns = Resolv.new
h = Hash.new

CSV.foreach(bFile) do |ip,up,upt,dn,dnt|
    if ip == "ip" then next end
    begin
        h[ip] = dns.getname(ip).to_s
    rescue Resolv::ResolvError
    end
end

file = File.open(dat_file, mode="w"){ |file|
    file.puts JSON.fast_generate(h)
}
