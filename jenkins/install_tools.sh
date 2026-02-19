#!/bin/bash
set -euxo pipefail

############################
# Update OS
############################
apt-get update -y
apt-get upgrade -y

############################
# Install Java 21 (Required for Jenkins)
############################
apt-get install -y openjdk-21-jdk fontconfig

java -version

############################
# Install Jenkins (LTS)
############################
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | gpg --dearmor \
  -o /usr/share/keyrings/jenkins-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

############################
# Install Terraform (Official HashiCorp Repo)
############################
apt-get install -y gnupg software-properties-common wget

wget -O- https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor \
  > /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y terraform

terraform --version

############################
# Open Jenkins Port
############################
ufw allow 8080 || true

echo "✅ Java 21, Jenkins, and Terraform installation completed"