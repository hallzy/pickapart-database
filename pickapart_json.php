<?php
/* Login for the default user of the database. */
/* This just authenticates database users. Since this is a public facing */
/* database, everyone uses this user so no big deal about leaving this here */
/* Especially because this user only has access to select statements anyways */
$username = "stmhallc_user";
$password = "04otmJr2K";
$db = "stmhallc_cars";
$servername = "localhost";

$con=mysqli_connect($servername, $username, $password, $db);
// Check connection
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }


$query = $_GET['query'];

/* Default query */
if ($query == '') {
    $query = "select * from cars order by make, model, year desc";
}

$query = str_replace ('unyon', 'union', $query);
$query = str_replace ('havin', 'having', $query);

$result = mysqli_query($con,$query);

$num_rows = mysqli_num_rows($result);

/* Need to get the names of the headings */
/* If we are looking for * then we don't care */
/* Make the query lowercase for easier parsing */
$mystring = strtolower($query);
if (strpos($mystring, " * ") == false) {
  /* Remove everything after "from" */
  $mystring = explode(" from", $mystring);
  /* Remove "select" */
  $mystring = explode("select", $mystring[0]);

  $mystring = $mystring[1];
  /* split by commas, if they exist */
  if (strpos($mystring, ",") != false) {
      $mystring = explode(",", $mystring);
  }


  /* We now have an array of each element being selected. Just need to check */
  /* if they have the "as" keyword */
  for ($i=0; $i<count($mystring); $i++) {
    /* split by commas, if they exist */
    if (count($mystring) == 1) {
      if (strpos($mystring, "as") != false) {
        $mystring = explode("as ", $mystring);
        $mystring = $mystring[1];
      }
    }
    else {
      if (strpos($mystring[$i], "as") != false) {
        $mystring[$i] = explode("as ", $mystring[$i]);
        $mystring[$i] = $mystring[$i][1];
      }
    }
  }
}
else {
    $mystring = array("date_added", "make", "model", "year", "body_style",
                      "engine", "transmission", "description", "row", "stock");

}

$arr = array();
$count=0;

while ($row    = mysqli_fetch_assoc($result)) {
  for ($i=0; $i<count($mystring); $i++) {
    if (count($mystring) == 1) {
      $label = $mystring;
    }
    else {
      $label = $mystring[$i];
    }
    $label = str_replace (' ', '', $label);
    $arr[$count][$label] = $row[$label];
  }
  $count++;
}
echo json_encode($arr);

mysqli_close($con);

?>
