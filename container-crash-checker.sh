#!/bin/bash

# Check for container crashes and echo found files immediately
find system-logs/nomad-jobs/ -name "*.json" | while read file; do
  if grep -q "Docker container exited with non-zero exit code: 137" "$file"; then
    echo "Found crash file: $file"
    # Extract timestamp and convert to human-readable format
    timestamp=$(jq < "$file" | grep -B 2 137 | grep "Time" | awk '{print $2}' | tr -d ',')
    seconds=$(echo "$timestamp / 1000000000" | bc)
    nanoseconds=$(echo "$timestamp % 1000000000" | bc)
    formatted_date=$(date -u -d @${seconds} +"%Y-%m-%d %H:%M:%S")
    formatted_nanoseconds=$(printf "%03d" $((nanoseconds/1000000)))
    human_readable_date="${formatted_date}.${formatted_nanoseconds}"
    echo "Crash Time: $human_readable_date"
  fi
done
