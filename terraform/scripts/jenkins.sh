#!/bin/bash
# Update system
sudo yum update -y

# Install Java (required by Jenkins)
sudo yum install -y java-11-openjdk

# Add Jenkins repo and install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins

# Start and enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
