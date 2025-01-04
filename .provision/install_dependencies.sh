#!/bin/bash

# Ensure script runs with correct permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo"
   exit 1
fi

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
apt-get install -y openjdk-8-jdk openssh-server openssh-client net-tools wget pdsh jq

# Set environment variables
HADOOP_VERSION="3.3.6"
HADOOP_TAR="hadoop-${HADOOP_VERSION}.tar.gz"
HADOOP_DIR="hadoop-${HADOOP_VERSION}"
HADOOP_HOME="/home/hadoop/hadoop"
WORK_DIR="/tmp"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

# Create work directory
mkdir -p "${WORK_DIR}"

# Create hadoop user's .bashrc content
sudo -u hadoop bash -c '
    echo -e "\
    export HADOOP_HOME=\"/home/hadoop/hadoop\"\n\
    export HADOOP_INSTALL=\"\${HADOOP_HOME}\"\n\
    export HADOOP_MAPRED_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_COMMON_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_HDFS_HOME=\"\${HADOOP_HOME}\"\n\
    export YARN_HOME=\"\${HADOOP_HOME}\"\n\
    export HADOOP_COMMON_LIB_NATIVE_DIR=\"\${HADOOP_HOME}/lib/native\"\n\
    export PATH=\"\${PATH}:\${HADOOP_HOME}/sbin:\${HADOOP_HOME}/bin\"\n\
    export HADOOP_OPTS=\"-Djava.library.path=\${HADOOP_HOME}/lib/native\"\n\
    export PDSH_RCMD_TYPE=\"ssh\"\n\
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

# Download Hadoop tarball to the work directory
echo "Downloading Hadoop ${HADOOP_VERSION} to ${WORK_DIR}"
if [ ! -f "${WORK_DIR}/${HADOOP_TAR}" ]; then
    wget "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_TAR}" -P "${WORK_DIR}/"
fi

# Validate Hadoop tarball
if [ ! -f "${WORK_DIR}/${HADOOP_TAR}" ]; then
    echo "ERROR: Hadoop tarball (${WORK_DIR}/${HADOOP_TAR}) not found. Exiting."
    exit 1
fi

# Extract and set up Hadoop in /home/hadoop
echo "Extracting Hadoop to ${HADOOP_HOME}"
sudo tar -xzf "${WORK_DIR}/${HADOOP_TAR}" -C /home/hadoop
sudo mv "${HADOOP_HOME}-${HADOOP_VERSION}/" "${HADOOP_HOME}/"

# Set permissions for Hadoop directory
echo "Setting permissions for Hadoop directory"
sudo chown -R hadoop:hadoop "${HADOOP_HOME}"

echo "Hadoop installation completed successfully"

# Get the hostname
HOSTNAME=$(hostname)

# Get the second IP address from `hostname -I`
IP=$(hostname -I | awk '{ print $2 }')

# Check if IP was successfully retrieved
if [[ -z "$IP" ]]; then
    echo "ERROR: Unable to retrieve the second IP address. Exiting."
    exit 1
fi

# File to store the JSON data
JSON_FILE="shared/config/hosts.json"

# Create directory if it doesn't exist
mkdir -p $(dirname "$JSON_FILE")

# Initialize or update the JSON file using jq
if [[ ! -f "$JSON_FILE" ]]; then
    # File doesn't exist, create new JSON file
    echo "Creating new ${JSON_FILE} file..."
    jq -n --arg hostname "$HOSTNAME" --arg ip "$IP" '{($hostname): $ip}' > "$JSON_FILE"
else
    # File exists, update or add new entry
    jq --arg hostname "$HOSTNAME" --arg ip "$IP" \
        '. + {($hostname): $ip}' "$JSON_FILE" > "${JSON_FILE}.tmp" && \
    mv "${JSON_FILE}.tmp" "$JSON_FILE"
fi

# Output success message
echo "Updated ${JSON_FILE}:"
cat "$JSON_FILE"