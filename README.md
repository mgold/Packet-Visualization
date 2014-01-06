# Packet Visualizations
Max Goldstein

This is a set of visualizations of network packets captured at DEF CON 2013.
The original data was 15GB of raw pcap files representing nearly 10 million
packets. Read the **[essay](http://www.eecs.tufts.edu/~mgolds07/packet_viz/)**
which explains and links to live demos.

For the first visualization, *multiview*, compression and binning
techniques reduce this information three-thousandfold, to 4.9MB of JSON and two
mid-sized png images with over 5000 numbers per inch. Specific views are tailored to
the data, including a world map of geoIPs and IP block distributions of uploads
arranged on a Hilbert curve.

The second viz shows the maximum *bandwidth* of the foreign hosts (uploads and
downloads). Immediate visual anomalies allow the detection of behavior that I
am actively exploring and attempting to explain.

## Requirements
See above for links to live demos. To run locally, download into the cloned
repo the following. (The second two are only needed for multiview.)
* [D3 (minimized)](http://d3js.org/d3.v3.min.js)
* [World Map JSON](https://gist.github.com/d3noob/5193723/raw/world-110m2.json)
* [Topojson v0](http://d3js.org/topojson.v0.min.js) (not v1!)

You only need to run the Ruby scripts if you want to analyze your own pcap
files; their outputs needed to run the viz on the DEF CON data are in `data/`.
(The raw and intermediate files have been omitted for space and security.)
But if you have your own data, you'll need the gems `packetfu` (1.1.9) and
`geoIP` (1.3.3), a geoIP database (I used `GeoLiteCity`), and an svg to png
conversion utility (change the path near the bottom of `svg.rb`).

## Technical Notes

This viz was made for the final project of COMP 116, Computer Security, with
Ming Chow at Tufts University, Fall 2013. I have addressed the biggest and most
visible concerns after turning it in, but there are still some rough edges.
Please excuse the haphazard code and the occasional grammatical error in the
paper. Also, the `svg` script is more fragile than I would like when it comes
to reducing the bin size, something about modulus.

The bandwidth visualization was made after the end of the semester, and I
consider it a more informative viz with a cleaner implementation.
