#!/bin/bash

# Check for container crashes and echo found files immediately
find system-logs/nomad-jobs/ -name "*.json" | while read file; do
  if grep -q "Docker container exited with non-zero exit code: 137" "$file"; then
    echo "Found exit137 in: $file"
    # Extract timestamp and convert to human-readable format
    # Handle multiple lines of timestamps correctly
    jq < "$file" | grep -B 2 137 | grep "Time" | awk '{print $2}' | tr -d ',' | while read timestamp; do
      # Ensure arithmetic operations are performed on individual lines to avoid syntax errors
      seconds=$(echo "$timestamp / 1000000000" | bc)
      nanoseconds=$(echo "$timestamp % 1000000000" | bc)
      # Process each timestamp individually
      if ! formatted_date=$(date -u +"%Y-%m-%d %H:%M:%S" --date="@${seconds}" 2>/dev/null); then
        echo "Invalid date for timestamp: ${timestamp}"
        continue
      fi
      formatted_nanoseconds=$(printf "%03d" $((nanoseconds/1000000)))
      human_readable_date="${formatted_date}.${formatted_nanoseconds}"
      # Include epoch time in the output line
      echo "epoch: ${timestamp}  Crash Time: $human_readable_date"
    done
  fi
done
