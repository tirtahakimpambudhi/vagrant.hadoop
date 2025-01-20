#!/bin/bash

echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

# Explicitly set absolute paths
export HADOOP_HOME="/home/hadoop/hadoop"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# Add Hadoop environment variables to .bashrc
sudo -u hadoop bash -c '
    echo -e "\
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"\n\
    export HADOOP_HOME="/home/hadoop/hadoop"\n\
    export HADOOP_INSTALL=\"\${HADOOP_HOME}\"\n\
    export HADOOP_MAPRED_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_COMMON_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_HDFS_HOME=\"\${HADOOP_HOME}\"\n\
    export YARN_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_COMMON_LIB_NATIVE_DIR=\"\${HADOOP_HOME}/lib/native\"\n\
    export PATH=\"\${PATH}:\${HADOOP_HOME}/sbin:\${HADOOP_HOME}/bin\"\n\
    export HADOOP_OPTS=\"-Djava.library.path=\${HADOOP_HOME}/lib/native\"\n\
    " >> ~/.bashrc
'

source .bashrc
# Step 7: Configure Hadoop
sudo -u hadoop mkdir -p ~/hadoopdata/hdfs/{namenode,datanode}
sudo chown hadoop:hadoop -R /home/hadoop/hadoopdata/hdfs 

# Step 7a: Configure hadoop-env.sh
echo "Editing hadoop-env.sh"
sudo -u hadoop sed -i "s|# export JAVA_HOME=.*|export JAVA_HOME=${JAVA_HOME}|" "${HADOOP_HOME}/etc/hadoop/hadoop-env.sh"

# Step 7b: Configure core-site.xml
echo "Configuring core-site.xml"
sudo bash -c "cat > ${HADOOP_HOME}/etc/hadoop/core-site.xml <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://0.0.0.0:9000</value>
    </property>
</configuration>
EOF"

# Step 7c: Configure hdfs-site.xml
echo "Configuring hdfs-site.xml"
sudo bash -c "cat > ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///home/hadoop/hadoopdata/hdfs/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///home/hadoop/hadoopdata/hdfs/datanode</value>
    </property>
 </configuration>
EOF"

# Step 7d: Configure mapred-site.xml
echo "Configuring mapred-site.xml"
sudo bash -c "cat > ${HADOOP_HOME}/etc/hadoop/mapred-site.xml <<EOF
<configuration>
   <property>
      <name>yarn.app.mapreduce.am.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME/home/hadoop/hadoop/bin/hadoop</value>
   </property>
   <property>
      <name>mapreduce.map.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME/home/hadoop/hadoop/bin/hadoop</value>
   </property>
   <property>
      <name>mapreduce.reduce.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME/home/hadoop/hadoop/bin/hadoop</value>
   </property>
</configuration>
EOF"

# Step 7e: Configure yarn-site.xml
echo "Configuring yarn-site.xml"
sudo bash -c "cat > ${HADOOP_HOME}/etc/hadoop/yarn-site.xml <<EOF
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
EOF"
echo "Change Permission Hadoop"
sudo chown hadoop:hadoop -R /home/hadoop/hadoop/
sudo chown hadoop:hadoop -R /usr/local/hadoop
sudo chown hadoop:hadoop -R /home/hadoop/hadoopdata/hdfs
sudo chown -R hdfs:hadoop /var/log/hadoop
# Step 8: Format the Hadoop NameNode
echo "Change Permission HadoopData"
sudo chown hadoop:hadoop -R /home/hadoop/hadoop/*
sudo chmod 777 /home/hadoop/hadoopdata/hdfs/datanode/
sudo chmod 777 /home/hadoop/hadoopdata/hdfs/namenode/
sudo chown -R hadoop:hadoop /home/hadoop/hadoopdata/

echo "Formatting the HDFS NameNode"
hdfs namenode -format

echo "Hadoop installation and configuration complete!"

# Final verification of environment variables
echo "Final environment setup:"
start-all.sh
