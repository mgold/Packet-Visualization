# Packet Visualization - [Live Demo](http://www.eecs.tufts.edu/~mgolds07/d3/)
Be sure to drag the mouse over the images on the left. It is best viewed
fullscreen on a 1080p monitor.

## Abstract
This is a visualization of network packets captured at DEF CON 2013. The
original data was 12.5GB of raw pcap files representing nearly 10 million
packets. Compression and binning techniques (see the pdf) reduce this
information more than one-thousandfold, to 7.1MB of JSON and two mid-sized png
images with over 5000 numbers per inch. The visualizations are customized to
the data, including a world map of geoIPs and IP block distributions of uploads
arranged on a Hilbert curve.

## Requirements
To run the visualization, download into the cloned repo the following.
* [D3 (minimized)](http://d3js.org/d3.v3.min.js)
* [World Map JSON](https://gist.github.com/d3noob/5193723/raw/world-110m2.json)
* [Topojson v0](http://d3js.org/topojson.v0.min.js) (not v1!)

You only need to run the Ruby scripts if you want to analyze your own pcap
files; the outputs needed to run the viz on the DEF CON data are in `data/`.
(The raw and intermediate files have been omitted for space and security.)
But if you have your own data, you'll need the gems `packetfu` (1.1.9) and
`geoIP` (1.3.3), a geoIP database (I used `GeoLiteCity`), and an svg to png
conversion utility (change the path near the bottom of `svg.rb`). Read the
paper for full details on the design and usage of these scripts.

## Technical Notes

This viz was made for the final project of COMP 116, Computer Security, with
Ming Chow at Tufts University, Fall 2013. I have addressed the biggest and most
visible concerns after turning it in, but there are still some rough edges.
Please excuse the haphazard code and the occasional grammatical error in the
paper. Also, the `svg` script is more fragile than I would like when it comes
to reducing the bin size, something about modulus.
