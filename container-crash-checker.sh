#!/bin/bash

# Check for container crashes
crash_files=$(cat system-logs/nomad-jobs/*.json | grep -Ril "Docker container exited with non-zero exit code: 137")

# Iterate through each result
for file in $crash_files; do
  echo "Checking file: $file"
  # Extract timestamp and convert to human-readable format
  timestamp=$(cat system-logs/nomad-jobs/$file | jq | grep -B 2 137 | grep "Time" | awk '{print $2}' | tr -d ',')
  seconds=$(echo "$timestamp / 1000000000" | bc)
  nanoseconds=$(echo "$timestamp % 1000000000" | bc)
  formatted_date=$(date -u -d @${seconds} +"%Y-%m-%d %H:%M:%S")
  formatted_nanoseconds=$(printf "%03d" $((nanoseconds/1000000)))
  human_readable_date="${formatted_date}.${formatted_nanoseconds}"
  echo "Crash Time: $human_readable_date"
done
