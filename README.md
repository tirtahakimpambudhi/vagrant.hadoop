
# Hadoop Automation with Vagrant

This project automates the setup of a Hadoop environment using Vagrant. The repository is designed to help you quickly deploy and manage a virtualized Hadoop cluster for learning, testing, or development purposes. It includes pre-configured scripts and workspaces for demonstrating Hadoop MapReduce functionality using Java.

## Features
- Automated setup of a Hadoop environment with Vagrant.
- Pre-configured scripts for Hadoop installation and configuration.
- Two sample MapReduce projects: **WordCount** and **SalesCountry**.
- Easy reformatting and reinitialization of HDFS if needed.

## Prerequisites
- Install [Vagrant](https://www.vagrantup.com/) on your machine.
- Install a supported virtualization provider such as [VirtualBox](https://www.virtualbox.org/).

## Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/tirtahakimpambudhi/vagrant.hadoop.git
   cd vagrant.hadoop
   ```

2. Start the virtual machine:
   ```bash
   vagrant up
   ```

3. SSH into the Hadoop master node:
   ```bash
   vagrant ssh hadoop-master
   # Or simply
   vagrant ssh
   ```

4. Run the setup script to configure Hadoop:
   ```bash
   bash shared/script/setup.sh
   ```

5. If you encounter any HDFS issues, you can reformat and reset HDFS using:
   ```bash
   bash shared/script/boot.sh
   ```

## Demonstration of MapReduce
This project includes two sample MapReduce workspaces: **WordCount** and **SalesCountry**. Both are implemented in Java and demonstrate the functionality of Hadoop.

### Running the WordCount Example
1. Inside the VM, execute the build script for WordCount:
   ```bash
   bash workspace/wordcount/build.sh
   ```

### Running the SalesCountry Example
1. Inside the VM, execute the build script for SalesCountry:
   ```bash
   bash workspace/salescountry/build.sh
   ```

## Reporting Issues
If you encounter any issues or have suggestions for improvement, feel free to report them or contribute via a pull request.

## Contributions
Contributions are welcome! If you'd like to add features or improve the project, please fork the repository and submit a pull request.

---

Thank you for using this repository! If you find it helpful, consider starring the project on GitHub. 😊
