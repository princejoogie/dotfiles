#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title timelog
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Log Timein/Timeout in HRIS
# @raycast.author princejoogie
# @raycast.authorURL https://github.com/princejoogie

response=$(curl 'http://10.0.1.146:200/Attendance/WebServices/TimeLogsEntry.asmx/TimeLogsEntry_Create' \
  -H 'Content-Type: application/json; charset=UTF-8' \
  -H 'X-Requested-With: XMLHttpRequest' \
  --data-raw '{"remarks":"ManualEntry","employeeID":"$FGI_EMPLOYEE_ID"}' \
  --insecure)

if echo "$response" | jq -e '.d == "true"' > /dev/null 2>&1; then
  echo "Success"
else
  echo "Failure: Unexpected response - $response"
fi
