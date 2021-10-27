#!/bin/bash

sudo apt update -y

sudo apt install git wget curl postgresql-client -y

wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb

sudo apt install ./jdk-17_linux-x64_bin.deb -y

sudo cat <<EOF | sudo tee /etc/profile.d/jdk.sh
export JAVA_HOME=/usr/lib/jvm/jdk-17/
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

sudo source /etc/profile.d/jdk.sh
