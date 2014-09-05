<?php

include 'postgresConfig.php';

header('Content-type: text/plain; charset=us-ascii');
header("Access-Control-Allow-Origin: *");
http_response_code(400);

$min_bw = intval($_GET["min_bw"]);
$min_bw > 0 or $_GET["min_bw"] === "0" or die("Bad minimum bandwidth");
$max_bw = intval($_GET["max_bw"]);
$max_bw !== 0 or die("Bad maximum bandwidth");
$min_bw <= $max_bw or die("min bw > max bw");

$min_ts = intval($_GET["min_ts"]);
$min_ts !== 0 or die("Bad minimum timestamp");
$max_ts = intval($_GET["max_ts"]);
$max_ts !== 0 or die("Bad maximum timestamp");
$min_ts <= $max_ts or die("min ts > max ts");

http_response_code(500);
$query="select count(*) from bw_max where bps < " . $max_bw . " and bps > " . $min_bw . " and ts < " . $max_ts . " and ts > " . $min_ts;
$result = pg_query($query) or die('Query failed: ' . pg_last_error());

http_response_code(200);
intval(pg_fetch_assoc($result)["count"]) < 10 or die("Error: Too many IPs");
http_response_code(500);

$query="create temporary table selectedIPs as (select distinct ip from bw_max where bps < " . $max_bw . " and bps > " . $min_bw . " and ts < " . $max_ts . " and ts > " . $min_ts ." limit 10)";
$result = pg_query($query) or die('Query failed: ' . pg_last_error());
$query="select bw.ip, dir, ts, bps from bw inner join selectedIPs on bw.ip = selectedIPs.ip order by bw.ip, dir, ts";
$result = pg_query($query) or die('Query failed: ' . pg_last_error());

http_response_code(200);
echo "ip,dir,ts,bps\n";
if(pg_num_rows($result)) {
  while($val = pg_fetch_assoc($result)) {
      echo $val["ip"].",".$val["dir"].",".$val["ts"].",".$val["bps"]."\n";
  }
}

pg_free_result($result);
pg_close($dbconn);

?>
