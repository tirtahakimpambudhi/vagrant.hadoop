#!/bin/bash

# Paths
source ~/.bashrc
SRC_DIR="src/main/java"
BUILD_DIR="build"
OUTPUT_DIR="wordcount/output"
INPUT_DIR="wordcount/input"
INPUT_FILE="input/input.txt"
JAR_NAME="WordCount.jar"
HADOOP_CLASSPATH="$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/mapreduce/*"

# Compile Java files
echo "Compiling Java files..."
mkdir -p $BUILD_DIR
javac -classpath $HADOOP_CLASSPATH -d $BUILD_DIR $SRC_DIR/wordcount/*.java

# Create JAR file
echo "Creating JAR file..."
jar cfm $JAR_NAME Manifest.txt -C $BUILD_DIR .

# Clean up previous output in HDFS
echo "Cleaning HDFS output directory..."
hdfs dfs -rm -r -f $OUTPUT_DIR
hdfs dfs -rm -r -f $INPUT_DIR

# Create directory Input and Output
hdfs dfs -mkdir -p $INPUT_DIR
hdfs dfs -copyFromLocal $INPUT_FILE $INPUT_DIR

# Run the JAR file
echo "Running Hadoop job..."
hadoop jar $JAR_NAME $INPUT_DIR $OUTPUT_DIR

# Display output
echo "Hadoop job output:"
hdfs dfs -cat $OUTPUT_DIR/part-r-00000
hdfs dfs -copyToLocal $OUTPUT_DIR/ output/
