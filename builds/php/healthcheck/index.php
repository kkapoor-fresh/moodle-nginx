<?php

// Tests health of application and reports critical components status to
// users via visual tabe display, or to UptimeRobot via HTTP response.

function test_database_connectivity($server = "localhost", $db = "moodle", $user = "moodle", $pass = "moodle") {
    // Test database connectivity
    $conn = new mysqli($server, $user, $pass, $db);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Calculate up-time
    $up_time = calculate_up_time($conn);

    // Display up-time
    echo "Connected successfully for " . $up_time . " seconds";
}

function calculate_up_time($conn) {
    // Get the current time
    $current_time = time();

    // Get the time the connection was established
    $start_time = $conn->thread_id;

    // Calculate up-time
    $up_time = $current_time - $start_time;

    return $up_time;
}

test_database_connectivity(
    'localhost',
    'moodle',
    'moodle',
    'rbBjP4dn*sLu7r9zm^&yPczZNc'
);
?>
