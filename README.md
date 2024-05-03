# container-crash-checker

Checking for container crashes with:

```
cat system-logs/nomad-jobs/*.json | grep -Ril "Docker container exited with non-zero exit code: 137"
```

From a list of container crashes:

```
system-logs/nomad-jobs/consul-template.consul-template[0].json
system-logs/nomad-jobs/token.backend[0].json
system-logs/nomad-jobs/token.frontend[0].json
system-logs/nomad-jobs/babeld.babeld[0].json
system-logs/nomad-jobs/pages-deployer-api.pages-deployer-api[0].json
system-logs/nomad-jobs/pages-deployer-worker.pages-deployer-worker[0].json
system-logs/nomad-jobs/artifactcache.backend[0].json
system-logs/nomad-jobs/artifactcache.frontend[0].json
system-logs/nomad-jobs/actions.frontend[0].json
system-logs/nomad-jobs/mps.backend[0].json
system-logs/nomad-jobs/actions.backend[0].json
system-logs/nomad-jobs/launch-worker.launch-worker[0].json
system-logs/nomad-jobs/mps.frontend[0].json
system-logs/nomad-jobs/mssql.mssql[0].json
```

looking at individual instances of 137's:

```
cat system-logs/nomad-jobs/mps.frontend[0].json | jq | grep -B 2 137
```

produces output like this:

```
[Bundle #123456] 123456 $ cat system-logs/nomad-jobs/mps.frontend[0].json | jq | grep -B 2 137
          "Type": "Terminated",
          "Time": 1700323960296048000,
          "Message": "Docker container exited with non-zero exit code: 137",
          "DisplayMessage": "Exit Code: 137, Exit Message: \"Docker container exited with non-zero exit code: 137\"",
          "Details": {
            "oom_killed": "false",
            "exit_message": "Docker container exited with non-zero exit code: 137",
            "exit_code": "137",
--
          "SetupError": "",
          "DriverError": "",
          "ExitCode": 137,
```

The epoch timestamp `1700323960296048000` needs to go through a converter like https://www.epochconverter.com/ which returns a result like:

```
Convert epoch to human-readable date and vice versa
1700323960296048000
 Timestamp to Human date  [batch convert]
Supports Unix timestamps in seconds, milliseconds, microseconds and nanoseconds.
Assuming that this timestamp is in nanoseconds (1 billionth of a second):
GMT: Saturday, November 18, 2023 4:12:40.296 PM
Your time zone: Saturday, November 18, 2023 8:12:40.296 AM GMT-08:00
Relative: 5 months ago
```

this tool will scan all the results and return the relative time of the container crash

To do this on a bundle this bash script will do it:

```
timestamp=1700323960296048000
seconds=$(echo "$timestamp / 1000000000" | bc)
nanoseconds=$(echo "$timestamp % 1000000000" | bc)
formatted_date=$(date -u -d @${seconds} +"%Y-%m-%d %H:%M:%S")
formatted_nanoseconds=$(printf "%03d" $((nanoseconds/1000000)))
echo "${formatted_date}.${formatted_nanoseconds}"
```

# To use:

Copy/paste the following into your terminal 
```
echo '#!/bin/bash

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
' > ccc.sh
chmod +x ccc.sh
```

run with:

```
./ccc.sh
```

results will tell you which files containers 137's and convert them to GMT

```
[Bundle #131491] 131491 $ ./container-crash-check.sh
Found exit137 in: system-logs/nomad-jobs/consul-template.consul-template[0].json
epoch: 1713989368357771500  Crash Time: 2024-04-24 20:09:28.357
Found exit137 in: system-logs/nomad-jobs/token.backend[0].json
epoch: 1713200806591068400  Crash Time: 2024-04-15 17:06:46.591
epoch: 1713989368407380200  Crash Time: 2024-04-24 20:09:28.407
Found exit137 in: system-logs/nomad-jobs/token.frontend[0].json
epoch: 1713200806804237600  Crash Time: 2024-04-15 17:06:46.804
epoch: 1713989368157206300  Crash Time: 2024-04-24 20:09:28.157
Found exit137 in: system-logs/nomad-jobs/mysql.mysql[0].json
epoch: 1713989368740230100  Crash Time: 2024-04-24 20:09:28.740
Found exit137 in: system-logs/nomad-jobs/babeld.babeld[0].json
epoch: 1713200806985290800  Crash Time: 2024-04-15 17:06:46.985
epoch: 1713989368339992800  Crash Time: 2024-04-24 20:09:28.339
Found exit137 in: system-logs/nomad-jobs/pages-deployer-api.pages-deployer-api[0].json
epoch: 1713200806884139300  Crash Time: 2024-04-15 17:06:46.884
epoch: 1713989368323414000  Crash Time: 2024-04-24 20:09:28.323
Found exit137 in: system-logs/nomad-jobs/pages-deployer-worker.pages-deployer-worker[0].json
epoch: 1713200806575738400  Crash Time: 2024-04-15 17:06:46.575
epoch: 1713989368314713000  Crash Time: 2024-04-24 20:09:28.314
Found exit137 in: system-logs/nomad-jobs/artifactcache.backend[0].json
epoch: 1713200806745746000  Crash Time: 2024-04-15 17:06:46.745
epoch: 1713989368174419700  Crash Time: 2024-04-24 20:09:28.174
Found exit137 in: system-logs/nomad-jobs/artifactcache.frontend[0].json
epoch: 1713200806283576600  Crash Time: 2024-04-15 17:06:46.283
epoch: 1713989368757532000  Crash Time: 2024-04-24 20:09:28.757
Found exit137 in: system-logs/nomad-jobs/actions.frontend[0].json
epoch: 1713200806270373000  Crash Time: 2024-04-15 17:06:46.270
epoch: 1713989368917609500  Crash Time: 2024-04-24 20:09:28.917
Found exit137 in: system-logs/nomad-jobs/mps.backend[0].json
epoch: 1713200806654149000  Crash Time: 2024-04-15 17:06:46.654
epoch: 1713989368466476000  Crash Time: 2024-04-24 20:09:28.466
Found exit137 in: system-logs/nomad-jobs/actions.backend[0].json
epoch: 1713200806680714800  Crash Time: 2024-04-15 17:06:46.680
epoch: 1713989368235224800  Crash Time: 2024-04-24 20:09:28.235
Found exit137 in: system-logs/nomad-jobs/mps.frontend[0].json
epoch: 1713200806933305900  Crash Time: 2024-04-15 17:06:46.933
epoch: 1713989368185980000  Crash Time: 2024-04-24 20:09:28.185
Found exit137 in: system-logs/nomad-jobs/mssql.mssql[0].json
epoch: 1713989368121627600  Crash Time: 2024-04-24 20:09:28.121
```

