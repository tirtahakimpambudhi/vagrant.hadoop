#!/bin/bash
source ~/.bashrc
echo "Formatting the HDFS NameNode"
hdfs namenode -format
sudo chown -R hadoop:hadoop /home/hadoop/hadoop/logs
echo "Hadoop installation and configuration complete!"
# Final verification of environment variables
echo "Final environment setup:"
start-all.sh
hdfs dfs -mkdir -p /user/hadoop
