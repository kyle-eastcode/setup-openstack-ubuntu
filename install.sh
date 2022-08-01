#!/bin/bash

# Welcome to the installation file for our custom deployment of OpenSatck self-hosted IaaS service. This installation
# file is designed for use on Ubuntu 20.04 LTS and includes some bootstrap security and monitoring tools along side
# of OpenStack IaaS service.

# Set the config variables used in the script
DELAY=3
USERNAME=stack

# Determine OS platform
FOUND_OS=$(lsb_release -d | awk -F"\t" '{print $2}')
FOUND_IP=$(hostname -I)

# Here is how we handle the exit of the install script
exit_install () {
	echo ""
	echo "Now exiting the installer..."
	
	sleep $DELAY

	exit 1
}

# Here is where we run updates, upgrades and install the required services
install_requirements () {
	echo ""
	echo "Running an update, upgrade and install the following required services:"
	echo "- snap"
	echo "- git"
	echo ""
	apt-get update -y
	echo ""
	apt-get upgrade -y
	echo ""
	apt-get install snapd git -y
	echo ""
	echo "Required services have been installed"
}

# Here is where we install some security tools
install_security () {
	echo ""
	echo "Next we will install Unattended Upgrades to keep Ubuntu secure and up-to-date..."
	echo ""
  apt-get install unattended-upgrades -y
	echo ""
	echo "Configuring Unattended Upgrades configuration..."
	echo ""
	dpkg-reconfigure --priority=low unattended-upgrades
	echo ""
	echo "Performing a dry-run to ensure Unattended Upgrades was configured properly..."
	echo ""
	unattended-upgrades --dry-run --debug
	echo ""
	echo "Unattended Upgrades installation complete"
}

# Here is where we install any monitoring tools
install_monitoring () {
	echo ""
	echo "Installing and setting up Monitoring agent..."
	echo ""
	echo "TODO: Will add this later..."
}

create_user () {
	echo ""
	echo "Creating a new user to install and run OpenStack..."
	echo ""
	adduser $USERNAME
	echo "$USERNAME:$ADMIN_PASSWORD" | chpasswd
	echo ""
	mkdir /opt/$USERNAME
	chown -R $USERNAME:$USERNAME /opt/$USERNAME
	echo "Adding sudo privileges to $USERNAME..."
	echo ""
	usermod -aG sudo $USERNAME
}

# Here is where we install OpenStack via DevStack
install_openstack () {
	echo ""
	echo "Now we will install OpenStack using DevStack"
	echo "For more information about DevStack, check out this link:"
	echo "- https://docs.openstack.org/devstack/latest"
	echo ""
	git clone https://git.openstack.org/openstack-dev/devstack
	cd devstack
	echo ""
	cat <<EOT >> local.conf
[[local|localrc]]

# Password for KeyStone, Database, RabbitMQ and Service
ADMIN_PASSWORD=$ADMIN_PASSWORD
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

# Host IP - get your Server/VM IP address from ip addr command
HOST_IP=$FOUND_IP
EOT

	echo ""
	cd ..
	su $USERNAME -c ./devstack/stack.sh
}

check_ports () {
	echo ""
	echo "After the installation is complete, we need to review our services and"
	echo "what ports those services might be listening on, this should be reviewed"
	echo "carfully and disable any unnecessary ports if possible"
	echo ""
	ss -ltpn
}

# Here is where the installation starts
start_install () {
	echo ""
	echo "Please enter a new Administrator password:"
	read -s ADMIN_PASSWORD
	echo ""
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $ADMIN_PASSWORD)

	echo "UBUNTU_USER=$USERNAME" >> .env
	echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> .env
	echo "OPENSTACK_IP_ADDRESS=$FOUND_IP" >> .env

	install_requirements

	sleep $DELAY

	install_security

	sleep $DELAY

	install_monitoring

	sleep $DELAY

	create_user

	sleep $DELAY

	install_openstack

	sleep $DELAY

	check_ports

	echo ""
	echo "Installtion script is complete, you may now access the OpenStack Dashboard"
	echo "by visiting this url: https://$FOUND_IP/dashboard"
	echo ""
	
	exit 1
}

# Here is the script controller, it will ask if the user wishes to continue with installtion
echo ""
read -p "About to install OpenStack on $FOUND_OS, are you sure your want to continue (y/n)? " choice
case "$choice" in 
  y|Y ) start_install;;
  n|N ) exit_install;;
  * ) echo "invalid";;
esac
