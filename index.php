<?php	
header("Cache-Control: no-cache, no-store, must-revalidate"); // HTTP 1.1.
header("Pragma: no-cache"); // HTTP 1.0.
header("Expires: 0"); // Proxies.
?>
<H1>My PHP App </H1>
<H3> Hello - S2Image </H1>
<img src="/a-abtesting.png">
<div>
<?php 
 echo "My Pod IP is : ".$_SERVER['SERVER_ADDR'] ;
 ?>
</div>

