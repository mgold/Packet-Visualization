require 'csv'
require 'date'
require 'json'
require 'geoip'

begin
    ppFile = ARGV[0]
rescue
    abort "Must supply preprocessed file on command line."
end

dat_file = "geoIPs.json"
geo = GeoIP.new('../multiview/GeoLiteCity.dat')
geoIPs = {}

CSV.foreach(ppFile) do |ts,cap,dir,ip_loc,pt_loc,ip_for,pt_for,proto,len|
    if !geoIPs.member?(ip_for)
        loc = geo.city ip_for
        if loc && (loc.longitude != 0 || loc.latitude != 0)
            geoIPs[ip_for] = [loc.longitude.round(4).to_s,
                              loc.latitude.round(4).to_s]
        end
    end
end

File.open(dat_file, mode="w"){ |file|
    file.puts JSON.fast_generate({geoIPs:geoIPs})
}
