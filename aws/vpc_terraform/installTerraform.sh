#!/bin/bash
# script for install terraform, must be run as root
# created by Andrii Rudyi, email: studentota2lvl@gmail.com


# variables
terraformVersion=0.12.23
os=linux
architecture=amd64
terraformDownloadLink=https://releases.hashicorp.com/terraform/"$terraformVersion"/terraform_"$terraformVersion"_"$os"_"$architecture".zip

# functions
function printPoint () {
	tput civis;
	while : 
	do
		for l in {1..4} ; do 
			case $l in 
				1)      
					printf "Please wait | \r"
          			;;
     			2)      
          			printf "Please wait / \r"
          			;;
				3)      
					printf "Please wait – \r"
          			;;
     			4)      
          			printf "Please wait \ \r"
					;;
			esac;
			sleep 0.2;
		done;
	done;
};

function installTerraform () {
	TEMP_FILE="$(mktemp)" &&

	apt-get update > /dev/null 2>&1 &&
	apt-get install unzip > /dev/null 2>&1 &&
	wget -O "$TEMP_FILE" "$terraformDownloadLink" > /dev/null 2>&1 &&
	unzip "$TEMP_FILE" > /dev/null 2>&1 &&
	mv terraform /usr/local/bin/ &&
	rm "$TEMP_FILE" &&
	unset TEMP_FILE;
}

function printRes () {
	if [ $? -eq 0 ]; 
	then
		echo "###############################################"
		echo "#                   DONE                      #"
		echo "#              `terraform --version`             #"
		echo "###############################################"
	fi
	tput cvvis;
}

# logic
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, like 'sudo ./installTerraform.sh'" 
   exit 1
else
	printPoint &
	printPointPid=$!;
	disown;
	installTerraform;
	kill "$printPointPid";
	printRes;
fi