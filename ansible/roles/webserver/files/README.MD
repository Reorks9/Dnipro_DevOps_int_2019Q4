### docker VM. [Instruction for Ubuntu](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04)

#### 1. install docker

    sudo apt-get update
    sudo apt install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

# another way
    sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
    sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable" &&
    sudo apt-get update &&
    sudo apt-get -y install docker-ce &&
    sudo gpasswd -a ${USER} docker &&
    #?  sudo usermod -aG docker ${USER} 
    sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose 

#### 2. oth for mee
    a=$(who | cut -d' ' -f1)
    sudo chgrp -R $a /var/www/
    sudo chmod -R g+rw /var/www/

    docker-compose --version
    sudo systemctl status docker

#### 2. links
#### 2. change hostname

    sudo hostnamectl set-hostname newNameHere
    sudo vim /etc/hosts
    sudo reboot