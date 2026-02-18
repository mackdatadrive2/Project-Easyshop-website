#!/bin/bash                                      # Shebang: tells the system to run this script using the Bash shell

sudo apt-get update -y                           # Updates the package index to get the latest versions of available packages

sudo apt-get install snapd -y                    # Installs Snap daemon, which allows installing software using snap packages

# Install AWS CLI
sudo snap install aws-cli --classic               # Installs AWS CLI using Snap; --classic gives full system access required by AWS CLI

# Install Helm
sudo snap install helm --classic                  # Installs Helm, the Kubernetes package manager, using Snap

# Install Kubectl
sudo snap install kubectl --classic               # Installs kubectl, the Kubernetes CLI tool, to manage EKS clusters
