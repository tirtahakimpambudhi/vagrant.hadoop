#!bin/bash

sudo mkdir script
source ~/.bashrc

# Set DNS server (Google DNS)
nameserver="8.8.8.8"
echo "nameserver $nameserver" | sudo tee /etc/resolv.conf > /dev/null

# Step 1: Check DNS connectivity (ping 8.8.8.8)
echo "Checking DNS connectivity..."
ping -c 4 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: DNS ping to 8.8.8.8 failed. Exiting."
    echo "ERROR: DNS ping to 8.8.8.8 failed. Exiting."
    exit 1
else
    echo "DNS connectivity is OK."
fi

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
echo -e "\
export JAVA_HOME="$JAVA_HOME"\n\
export HADOOP_HOME="$HADOOP_HOME"\n\
export HADOOP_INSTALL=\"\${HADOOP_HOME}\"\n\
export HADOOP_MAPRED_HOME=\"\${HADOOP_HOME}\"\n\
export HADOOP_COMMON_HOME=\"\${HADOOP_HOME}\"\n\
export HADOOP_HDFS_HOME=\"\${HADOOP_HOME}\"\n\
export YARN_HOME=\"\${HADOOP_HOME}\"\n\
export HADOOP_COMMON_LIB_NATIVE_DIR=\"\${HADOOP_HOME}/lib/native\"\n\
export PATH=\"\${PATH}:\${HADOOP_HOME}/sbin:\${HADOOP_HOME}/bin\"\n\
export HADOOP_OPTS=\"-Djava.library.path=\${HADOOP_HOME}/lib/native\"\n\
" >> ~/.bashrc

# Source .bashrc to apply changes
source .bashrc

# Step 2: Set up Hadoop environment variables
echo "Validation Hadoop environment variables"

if [ -z "${HADOOP_HOME}" ] || [ -z "${JAVA_HOME}" ]; then
    echo "ERROR: Environment variables not set properly"
    echo "ERROR: Environment variables not set properly"
    exit 1
fi


# Step 2a: Install required packages (OpenJDK and SSH)
echo "Installing OpenJDK 8 and SSH"
sudo apt install openjdk-8-jdk openssh-server openssh-client net-tools -y
echo "Successfully installed Java (OpenJDK 8) and SSH"

# Step 3: Check if Java is installed
echo "Checking if Java is installed..."
java -version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Java is not installed. Exiting."
    echo "ERROR: Java is not installed. Exiting."
    exit 1
else
    echo "Java is installed."
fi

# Step 4: Generate SSH keys for the hadoop user

# echo "Successfully generated SSH keys for user 'hadoop'"

# Step 5: Download and install Hadoop
HADOOP_VERSION="3.3.6"
HADOOP_TAR="hadoop-${HADOOP_VERSION}.tar.gz"
HADOOP_DIR="hadoop-${HADOOP_VERSION}"

# Explicitly set absolute paths
echo "Downloading Hadoop ${HADOOP_VERSION}"
if [ ! -f "${HADOOP_TAR}" ]; then
   sudo wget "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/${HADOOP_TAR}"
fi

# Create Hadoop Directory
if [ -d "$HADOOP_HOME" ]; then  
    echo "$HADOOP_HOME exist"  
else  
    echo "$HADOOP_HOME not exist"  
    sudo mkdir -p "${HADOOP_HOME}"
    echo "$HADOOP_HOME has ben created"
fi  

# Validate if the Hadoop tarball file exists
if [ ! -f "${HADOOP_TAR}" ]; then
    echo "ERROR: Hadoop tarball (${HADOOP_TAR}) not found. Exiting."
    echo "ERROR: Hadoop tarball (${HADOOP_TAR}) not found. Exiting."
    exit 1
fi

echo "Extracting Hadoop"
sudo tar -xzf "${HADOOP_TAR}"

echo "Renaming Hadoop directory"
sudo rm -rf "${HADOOP_HOME}"
sudo mv "${HADOOP_DIR}" "${HADOOP_HOME}"

sudo chown hadoop:hadoop -R $HADOOP_HOME/


