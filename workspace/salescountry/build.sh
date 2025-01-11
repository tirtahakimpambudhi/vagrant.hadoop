#!/bin/bash

# Paths
source ~/.bashrc
SRC_DIR="src/main/java"
BUILD_DIR="build"
OUTPUT_DIR="/salescountry/output"
INPUT_DIR="/salescountry/input"
JAR_NAME="SalesCountry.jar"
INPUT_FILE="input/SalesJan2009.csv"
HADOOP_CLASSPATH="$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/mapreduce/*"


# Compile Java files
echo "Compiling Java files..."
mkdir -p $BUILD_DIR
rm -rf $BUILD_DIR/* && rm -rf $JAR_NAME

javac -classpath $HADOOP_CLASSPATH -d $BUILD_DIR $SRC_DIR/salescountry/*.java

# Create JAR file
echo "Creating JAR file..."
jar cfm $JAR_NAME Manifest.txt -C $BUILD_DIR .

# Clean up previous output in HDFS
echo "Cleaning HDFS output directory..."
hdfs dfs -rm -r -f $OUTPUT_DIR
hdfs dfs -rm -r -f $INPUT_DIR
rm -rf output/*

# Create directory Input and Output
hdfs dfs -mkdir -p $INPUT_DIR
hdfs dfs -copyFromLocal $INPUT_FILE $INPUT_DIR

# Run the JAR file
echo "Running Hadoop job..."
hadoop jar $JAR_NAME $INPUT_DIR $OUTPUT_DIR
# To show list application running in job hadoop cluster
yarn application -list


# Display output
echo "Hadoop job output:"
hdfs dfs -cat $OUTPUT_DIR/part-00000
hdfs dfs -copyToLocal $OUTPUT_DIR/ output/
