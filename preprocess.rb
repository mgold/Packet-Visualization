require 'rubygems'
require 'logger'
require 'packetfu'
include PacketFu

if ARGV.length < 2
    abort "Must supply pcap range on command line."
end

pcapStart = ARGV[0].to_i
pcapEnd   = ARGV[1].to_i

# initialize
$h = Hash.new()
$h.default = 0
$outf = File.new('/data/wos/done/pp.'+pcapStart.to_s+'-'+pcapEnd.to_s+'.csv', 'w')
$logger = Logger.new('/data/wos/log/pp.'+pcapStart.to_s+'-'+pcapEnd.to_s+'.log')

# main execution loop is located at end of file

def okIP(addr)
return addr != "0.0.0.0" &&
       addr != "255.255.255.255" &&
       !addr.match(/^169\.254.*/) &&
       !addr.match(/^10.*/) &&
       !addr.match(/^172\.[1-3].*/) && # TODO: match the block better
       !addr.match(/^192\.168.*/)
end

def processPcap(pcapFile, capNum)
    dltotal = 0
    $logger.info('Reading pcap file '+capNum.to_s+', filename '+pcapFile+'.')
    packets = PacketFu::PcapPackets.new.read(File.open(pcapFile) {|f| f.read})
    $logger.info('Done reading pcap file, starting analysis.')
    packets.each { |p|
        ut = p.timestamp
        ts = ut.sec.to_i.to_s + "." + ut.usec.to_i.to_s
        packet = PacketFu::Packet.parse(p.data)
        if packet.is_ip?
            is_dn = okIP(packet.ip_saddr)
            is_up = okIP(packet.ip_daddr)
            if is_dn ^ is_up
                ip = is_dn ? packet.ip_saddr : packet.ip_daddr
                type = is_dn ? "dn" : "up"
                len = packet.ip_calc_len.to_s
                $outf.puts [ts,capNum,ip,type,len].join(",")
            end
        end
    }
    $logger.info('Done with this pcap file.')
end

# main execution loop
(pcapStart..pcapEnd).each do |capNum|
    begin
        pcapFile = "/data/wos/wos_2013_day1a.pcap"
        if capNum > 0
            pcapFile << capNum.to_s
        end
        processPcap(pcapFile, capNum.to_s)
    rescue Exception => e
        $logger.fatal e
        raise e
    end
end
$logger.info "Preprocessing completed."

