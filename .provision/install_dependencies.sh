#!/bin/bash

# Ensure script runs with correct permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo"
   exit 1
fi

# Create script directory
mkdir -p /home/hadoop/script
chown hadoop:hadoop /home/hadoop/script

# Set DNS server (Google DNS)
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

# Check DNS connectivity
echo "Checking DNS connectivity..."
if ! ping -c 4 8.8.8.8 > /dev/null 2>&1; then
    echo "ERROR: DNS ping to 8.8.8.8 failed. Exiting."
    exit 1
fi
echo "DNS connectivity is OK."

# Install required packages
echo "Installing OpenJDK 8 and SSH"
apt-get update
apt-get install -y openjdk-8-jdk openssh-server openssh-client net-tools wget

# Set environment variables
HADOOP_VERSION="3.3.6"
HADOOP_TAR="hadoop-${HADOOP_VERSION}.tar.gz"
HADOOP_DIR="hadoop-${HADOOP_VERSION}"
HADOOP_HOME="/home/hadoop/hadoop"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
# Create hadoop user's .bashrc content
sudo -u hadoop bash -c '
    echo -e "\
    export \n\
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

# Source the new .bashrc
sudo -u hadoop bash -c "source /home/hadoop/.bashrc"

# Check if Java is installed
echo "Checking if Java is installed..."
if ! java -version > /dev/null 2>&1; then
    echo "ERROR: Java is not installed. Exiting."
    exit 1
fi
echo "Java is installed."

# Download and install Hadoop
echo "Downloading Hadoop ${HADOOP_VERSION}"
cd /home/hadoop
if [ ! -f "${HADOOP_TAR}" ]; then
    sudo -u hadoop wget "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_TAR}"
fi

# Validate hadoop tarball
if [ ! -f "${HADOOP_TAR}" ]; then
    echo "ERROR: Hadoop tarball (${HADOOP_TAR}) not found. Exiting."
    exit 1
fi

# Extract and set up Hadoop
echo "Extracting Hadoop"
sudo -u hadoop tar -xzf "${HADOOP_TAR}"

echo "Setting up Hadoop directory"
rm -rf "${HADOOP_HOME}"
mv "${HADOOP_DIR}" "${HADOOP_HOME}"
chown -R hadoop:hadoop "${HADOOP_HOME}"

echo "Hadoop installation completed successfully"