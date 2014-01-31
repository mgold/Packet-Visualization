<?php

include 'mysqlConfig.php';

header('Content-type: text/plain; charset=us-ascii');
header("Access-Control-Allow-Origin: *");

@mysql_select_db($dsn) or die( "Unable to select database");

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

$query="select ip from bw_max where bps < " . $max_bw . " and bps > " . $min_bw . " and ts < " . $max_ts . " and ts > " . $min_ts;
$result = mysql_query($query);

if(mysql_num_rows($result)) {
  while($value = mysql_fetch_assoc($result)) {
          echo $value["ip"] . "\n";
      }
}

mysql_close();

?>
