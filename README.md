# Packet Visualization - [Live Demo](http://www.eecs.tufts.edu/~mgolds07/d3/)
Be sure to drag the mouse over the images on the left. It is best viewed
fullscreen on a 1080p monitor.

## Abstract
This is a visualization of network packets captured at DEF CON 2013. The
original data was 12.5GB of raw pcap files representing nearly 10 million
packets. Compression and binning techniques (see the pdf) reduce this
information more than one-thousandfold, to 7.1MB of JSON and two mid-sized png
images with over 5000 numbers per inch. The visualizations are customized to
the data, including a world map of geoIPs and IP block distributions arranged on a
Hilbert curve.

## Requirements
To run the visualization, download into the cloned repo the following.
* [D3 (minimized)](http://d3js.org/d3.v3.min.js)
* [world map](https://gist.github.com/d3noob/5193723/raw/world-110m2.json)
* [topojson v0](http://d3js.org/topojson.v0.min.js) (not v1!)
