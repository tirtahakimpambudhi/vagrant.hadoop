#!/bin/bash
source .bashrc
echo "Stop all component Hadoop"
stop-all.sh
rm -f /tmp/hadoop-hadoop-*.pid
echo "Successfully stop all component hadoop"