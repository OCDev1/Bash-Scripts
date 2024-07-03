cool script to test and log your network speed using speedtest-cli.
as usual change the placeholders to fit your needs

#!/bin/bash
LOG_FILE="/path/to/save/speedtest_log.txt"
speedtest-cli >> $LOG_FILE
echo "Network speed test completed and logged."
