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

