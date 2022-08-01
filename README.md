# Setup OpenStack Ubuntu

This is a simple helper script to get started with OpenStack with a few Security and Monitoring add-ons included.

<br />

## Requirements

To get started, you can start with a fresh copy of Ubuntu installed.

 - This script is desiged to be run on Ubuntu 18.04 and latter.
 - This script requires that you have `sudo` privileges

<br />

## What does this script do?

This script was designed to add a few security tools and monitoring along side a
standard deployment of OpenStack for self-hosted IaaS on local or on-prem machines.
Once the script has completed, you will have a running instance of OpenStack with
a monitoring agent installed and configured and unattended upgrades installed
to keep the ubuntu instance up-to-date and secure.

## Getting Started

To get started, clone this repo with the following command:

`git clone https://github.com/kyle-eastcode/setup-openstack-ubuntu.git`

<br />

Next, cd into the `setup-openstack-ubuntu` and run the script.

`cd setup-openstack-ubuntu && sudo ./install.sh`

<br />
