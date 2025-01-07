#!/bin/bash

#  ================ WARNING RUNNING ONLY IF THE HADOOP ISSUES ==========================

# Stop all process hadoop
source .bashrc
echo "Stop all component Hadoop"
stop-all.sh
rm -f /tmp/hadoop-hadoop-*.pid
echo "Successfully stop all component hadoop"

# 1. Remove hadoopdata
rm -rf /home/hadoop/hadoopdata
# 2. Create again hadoopdata
mkdir -p /home/hadoop/hadoopdata/hdfs/{namenode,datanode}
# 3. Change Permission
sudo chown hadoop:hadoop -R /home/hadoop/hadoopdata/hdfs 
echo "Change Permission Hadoop"
sudo chown hadoop:hadoop -R /home/hadoop/hadoop/
sudo chown hadoop:hadoop -R /home/hadoop/hadoopdata/hdfs
echo "Change Permission HadoopData"
sudo chown hadoop:hadoop -R /home/hadoop/hadoop/*
sudo chmod 777 /home/hadoop/hadoopdata/hdfs/datanode/
sudo chown -R hadoop:hadoop /home/hadoop/hadoopdata/
# 4. Start again hadoop
source ~/.bashrc
echo "Formatting the HDFS NameNode"
hdfs namenode -format
sudo chown -R hadoop:hadoop /home/hadoop/hadoop/logs
echo "Hadoop installation and configuration complete!"
# Final verification of environment variables
echo "Final environment setup:"
start-all.sh
hdfs dfs -mkdir -p /user/hadoop