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

def dport(pkt)
    if pkt.is_tcp?
        pkt.tcp_dport
    elsif pkt.is_udp?
        pkt.udp_dport
    else
        ''
    end
end

def sport(pkt)
    if pkt.is_tcp?
        pkt.tcp_sport
    elsif pkt.is_udp?
        pkt.udp_sport
    else
        ''
    end
end

def processPcap(pcapFile, capNum)
    dltotal = 0
    $logger.info('Reading pcap file '+capNum.to_s+', filename '+pcapFile+'.')
    packets = PacketFu::PcapPackets.new.read(File.open(pcapFile) {|f| f.read})
    $logger.info('Done reading pcap file, starting analysis.')
    packets.each { |p|
        packet = PacketFu::Packet.parse(p.data)
        if packet.is_ip?
            is_dn = okIP(packet.ip_saddr)
            is_up = okIP(packet.ip_daddr)
            if is_dn ^ is_up
                if is_up
                    ip_loc = packet.ip_saddr
                    ip_for = packet.ip_daddr
                    pt_loc = sport packet
                    pt_for = dport packet
                    dir = :up
                else
                    ip_loc = packet.ip_daddr
                    ip_for = packet.ip_saddr
                    pt_loc = dport packet
                    pt_for = sport packet
                    dir = :dn
                end
                ts = p.timestamp.sec.to_f + p.timestamp.usec.to_f / 1000000.0
                prot = packet.proto[-1]
                if pt_for == 80 and prot == "TCP"
                    http = packet.payload[/^(GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS|CONNECT|PATCH)/] ||
                           packet.payload[/^HTTP\S* [0-9]{3}/].to_s[-3..-1]
                    if http then prot = "HTTP " + http end
                end
                len = packet.ip_calc_len.to_s
                $outf.puts [ts,capNum,dir,ip_loc,pt_loc,ip_for,pt_for,prot,len].join(",")
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

