# Function to log messages to a log file
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Set DNS server (Google DNS)
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
log_message "Set Google DNS in resolv.conf"

# Update package lists
sudo apt-get update -y
log_message "Updated package lists"

# Function to create a new user
create_user() {
    username=$1
    password=$2

    sudo useradd -m -s /bin/bash $username
    echo "$username:$password" | sudo chpasswd
    sudo usermod -aG sudo $username

    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
    log_message "User '$username' created with password '$password' and added to sudoers"
}

# Create the 'hadoop' user and set password
create_user "hadoop" "hadoop"

# Create .bashrc file if it does not exist
if [ ! -f /home/hadoop/.bashrc ]; then
    sudo cp ~/.bashrc /home/hadoop/.bashrc
    sudo chmod 644 /home/hadoop/.bashrc
    sudo chown hadoop:hadoop /home/hadoop/.bashrc
    log_message ".bashrc created for user 'hadoop'"
fi

# Generate SSH keys
sudo -u hadoop ssh-keygen -t rsa -b 2048 -N '' -f /home/hadoop/.ssh/id_rsa
sudo -u hadoop cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
sudo chown -R hadoop:hadoop /home/hadoop/.ssh
sudo chmod 700 /home/hadoop/.ssh
sudo chmod 600 /home/hadoop/.ssh/authorized_keys
log_message "SSH keys generated for user 'hadoop'"
