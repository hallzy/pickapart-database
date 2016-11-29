<?php

$update_date = "5:00pm PST November 28th 2016";
echo "Last Updated: $update_date";
echo "<br>";
echo "<br>";
echo "To use this, append \"?query=\" to the url followed by your sql query";
echo "<br>";
echo "<br>";
echo "The only table to query from is \"cars\"";
echo "<br>";
echo "For example, the default query is:";
echo "<br>";
echo "    SELECT * FROM cars ORDER BY make, model, year desc";

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

$result = mysqli_query($con,$query);


/* Need to get the names of the headings */
/* If we are looking for * then we don't care */
/* Make the query lowercase for easier parsing */
$mystring = strtolower($query);
if (strpos($mystring, "*") == false) {
  /* Remove everything after "from" */
  $mystring = explode(" from", $mystring);
  /* Remove "select" */
  $mystring = explode("select", $mystring[0]);

  $mystring = $mystring[1];
  /* split by commas, if they exist */
  if (strpos($mystring, ",") != false) {
      $mystring = explode(", ", $mystring);
  }

  /* We now have an array of each element being selected. Just need to check */
  /* if they have the "as" keyword */
  for ($i=0; $i<count($mystring); $i++) {
    /* split by commas, if they exist */
    if (strpos($mystring[$i], "as") != false) {
      $mystring[$i] = explode("as ", $mystring[$i]);
      $mystring[$i] = $mystring[$i][1];
    }
  }
}
else {
    $mystring = array("date_added", "make", "model", "year", "body_style",
                      "engine", "transmission", "description", "row", "stock");

}


echo "<table border='1'><tr>";
for ($i=0; $i<count($mystring); $i++) {
  $label = $mystring[$i];
  $label = str_replace (' ', '', $label);
  echo "<th>$label</th>";
}
echo "</tr>";

while ($row    = mysqli_fetch_assoc($result)) {
  echo "<tr>";
  for ($i=0; $i<count($mystring); $i++) {
    $label = $mystring[$i];
    $label = str_replace (' ', '', $label);
    echo "<td>" . $row[$label] . "</td>";
  }
  echo "</tr>";
}
echo "</table>";

mysqli_close($con);



?>
