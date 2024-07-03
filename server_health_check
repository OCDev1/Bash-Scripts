update the macros to fit your needs, I put placeholders in order to not expose any private info

#!/bin/bash
SERVER="remote.server.com"
EMAIL="your-email@example.com"
ping -c 4 $SERVER > /dev/null
if [ $? -ne 0 ]; then
  echo "Server $SERVER is down!" | mail -s "Server Down Alert" $EMAIL
else
  echo "Server $SERVER is up."
fi
