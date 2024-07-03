A script to generate a report of disk usage for all mounted filesystems.
change the path in line 7 to set the destination for the report

bash
Copy code
#!/bin/bash
df -h > Desktop/disk_usage_report.txt
echo "Disk usage report generated."
