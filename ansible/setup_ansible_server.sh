#!/bin/bash
# $1 - Access Key ID
# $2 - Secret Access Key
# to run: 
# sudo chmod +x ./setup_ansible_server.sh && sudo ./setup_ansible_server.sh AKIAJ7KKPII5DKMfdfdJI2ZA 0iUajOws2b7J/DKBLf5I4IUnBayJ2df9bLk6/Ss/HinR+E eu-central-1

ansibleUser=ansible;
jenkinsUser=jenkins;
GIT_HUB_USER_NAME=studentota2lvl;
GIT_HUB_USER_EMAIL="studentota2lvl@gmail.com";
keys_folder=/home/"$ansibleUser"/ssh_keys

# add user for ansible and jenkins 
groupadd "$ansibleUser";
groupadd "$jenkinsUser";
useradd -g "$ansibleUser" -G "$jenkinsUser",sudo -s /bin/bash -d /home/"$ansibleUser" -m "$ansibleUser";  
useradd -g "$jenkinsUser" -G "$ansibleUser",sudo -s /bin/bash -d /home/"$jenkinsUser" -m "$jenkinsUser";  

# create folders
mkdir -p /home/"$ansibleUser"/tempData/todo/back;
mkdir -p /home/"$ansibleUser"/tempData/todo/front;
mkdir -p /home/"$ansibleUser"/tempData/jenkinsBackup;
mkdir -p /home/"$ansibleUser"/tempData/dockerData;
mkdir -p /home/"$jenkinsUser"/jenkinsToS3Backup;
chmod -R g+rw /home/"$jenkinsUser"/jenkinsToS3Backup;
chmod -R g+rwx /home/"$ansibleUser"/;

# install and setup git
apt-get update;
apt-get install git;
git config --global user.name "$GIT_HUB_USER_NAME"
git config --global user.email "$GIT_HUB_USER_EMAIL"
mkdir -p /home/"$ansibleUser"/.ssh
ssh-keyscan "github.com">> /home/"$ansibleUser"/.ssh/known_hosts

# install python python-pip and ansible
apt-get update;
apt -y install python3.6;
apt -y install python3-pip;
pip3 install boto boto3 ansible;
pip3 install --upgrade requests;

# install AWS CLI
apt-get update;
apt -y install unzip;
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip";
unzip awscliv2.zip;
sudo ./aws/install;
rm awscliv2.zip;

# install build env
# - install node.js
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs

# create ssh-key for connect jenkins to ansible (will send to jenkins in deploy stage)
mkdir -p "$keys_folder"
ssh-keygen -t rsa -b 4096 -N '' -f "$keys_folder"/jenkins_to_ansible_key;
cat "$keys_folder"/jenkins_to_ansible_key.pub >> /home/"$ansibleUser"/.ssh/authorized_keys;

# create ssh-key for connect ansible to git
ssh-keygen -t rsa -b 4096 -N '' -f "$keys_folder"/ansible_to_git_key;
cp "$keys_folder"/ansible_to_git_key /home/"$ansibleUser"/.ssh/id_rsa

# create ssh-key for aws (well send to aws and use for all created VM)
ssh-keygen -t rsa -b 4096 -N '' -f "$keys_folder"/ansible_to_aws_key
cp "$keys_folder"/ansible_to_aws_key* /home/"$ansibleUser"/.ssh/

# set permission to .ssh folder
chmod 700 /home/"$ansibleUser"/.ssh
chmod 600 /home/"$ansibleUser"/.ssh/*
chmod 644 /home/"$ansibleUser"/.ssh/authorized_keys
chmod 644 /home/"$ansibleUser"/.ssh/known_hosts
chmod 644 /home/"$ansibleUser"/.ssh/*.pub

# set owner for ansible home
chown -R "$ansibleUser":"$ansibleUser" /home/ansible/*

#setup AWS python modules
mkdir -p /home/"$ansibleUser"/.aws/
aws_folder=/home/"$ansibleUser"/.aws
# set credentials
touch "$aws_folder"/credentials;
echo '[default]'>>"$aws_folder"/credentials;
echo AWS_ACCESS_KEY_ID="$1">>"$aws_folder"/credentials;
echo AWS_SECRET_ACCESS_KEY="$2">>"$aws_folder"/credentials;
# set configs
touch "$aws_folder"/config;
echo '[default]'>>"$aws_folder"/config;
echo region="$3">>"$aws_folder"/config;
# # export aws keys if needed
# export AWS_ACCESS_KEY_ID="$1" &&
# export AWS_SECRET_ACCESS_KEY="$2" &&
# export AWS_DEFAULT_REGION="$3";

echo '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
echo '@                        WARNING:                         @'
echo '@        PLEASE ADD PUBLIC SSH KEY TO YOUR GIT REPO       @'
echo '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
cat "$keys_folder"/ansible_to_git_key.pub
echo '##########################################'
echo '#                  DONE                  #'
echo '##########################################'