require 'csv'
require 'date'

binSize = 3
max_dl = 1500
scale_fac = 3
height = max_dl / scale_fac

begin
    ppFile = ARGV[0]
    pcapRange = ppFile.match(/[0-9]*-[0-9]*/)[0]
rescue
    abort "Must supply preprocessed file on command line."
end

up_file = "up."+pcapRange+".svg"
dn_file = "dn."+pcapRange+".svg"

last_break = -1
up_cols = []
up_col = [0] * height
dn_cols = []
dn_col = [0] * height
CSV.foreach(ppFile) do |row|
    ut,cap,ip,dir,cnt = row
    ts = Time.at(ut.to_i)
    if ts.sec % binSize == 0 && last_break != ts.sec
        last_break = ts.sec
        up_cols << up_col
        dn_cols << dn_col
        up_col = [0] * height
        dn_col = [0] * height
    end
    if dir == "dn"
        dn_col[(cnt.to_i - 1) / scale_fac] += 1
    elsif dir == "up"
        up_col[(cnt.to_i - 1) / scale_fac] += 1
    else
        abort "Got unrecognized directuon #{dir} in capture #{cap}"
    end
end

# use the same color scale for uploads and downloads
vals = (dn_cols.flatten.concat(up_cols.flatten)).sort
z = vals.index{|i|i>2}
n = vals.length - z
p50 = vals[(n*0.50).to_i + z]
p80 = vals[(n*0.80).to_i + z]
p95 = vals[(n*0.95).to_i + z]
cutoffs = [0, 1, 2, p50, p80, p95]
colors = ["000000", "000045", "0000AD", "009C00", "ADD900", "D98600", "E80000"]

$stderr.puts

# precondition: cutoffs.length <= colors.length
# precondition: cutoffs is sorted
def mk_svg filename, cols, colors, cutoffs
    width = cols.length
    height = cols[0].length

    file = File.open(filename, mode="w")
    file.puts '<?xml version="1.0" standalone="no"?>'
    file.puts '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
    file.puts '<svg viewBox = "0 0 '+width.to_s+' '+height.to_s+'" version = "1.1">'

    cols.each_with_index do |col, i|
        col.each_with_index do |v, j|
            color = ""
            cutoffs.each_with_index do |cutoff, k|
                if v <= cutoff
                    color = colors[k]
                    break
                end
            end
            if color == ""
                color = colors.last
            end
            file.puts '<rect x="'+i.to_s+'" y="'+j.to_s+'" width="1" height="1" fill="#'+color+'"/>'
        end
    end

    file.puts '</svg>'

    # Not exactly portable ...
    #system("/Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "+filename.gsub("svg", "png")+" "+filename)
    $stderr.puts "/Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png "+filename.gsub("svg", "png")+" "+filename

end

mk_svg up_file, up_cols, colors, cutoffs
mk_svg dn_file, dn_cols, colors, cutoffs

