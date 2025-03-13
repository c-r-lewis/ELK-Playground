#!/bin/bash
# Stop Suricata
sudo systemctl stop suricata

# Clear the log files
sudo truncate -s 0 /var/log/suricata/fast.log
sudo truncate -s 0 /var/log/suricata/eve.json
sudo truncate -s 0 /var/log/suricata/stats.log

# Start Suricata
sudo systemctl start suricata

echo "Suricata logs have been cleared."
