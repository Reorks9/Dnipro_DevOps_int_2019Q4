pipeline {
  agent any
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/back-TODO.git"
    ANSIBLE_SERVER_USER = "jenkins"
    ANSIBLE_SERVER_ADDR = "192.168.0.115" // static ansible server ip
    ANSIBLE_SERVER_PATH = "~/todo/back"
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~build env~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stages {
    stage('build env') {
      steps{
        echo '~~~~~~~~~~~build env~~~~~~~~~~~'
        sh 'git config --global user.name "$GIT_HUB_USER_NAME"'
        sh 'git config --global user.email "$GIT_HUB_USER_EMAIL"'
        sh 'mkdir -p ~/.ssh'
        sh 'ssh-keyscan "github.com">> ~/.ssh/known_hosts'
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Clone repo~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Repo cloning') {
      steps {
        echo '~~~~~~~~~~~Cloning repo with app~~~~~~~~~~~'
        sshagent (credentials: ['ssh_key_for_github']) {
          sh 'git clone "$GIT_HUB_REPO" ./'
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~send files to web server~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('send files to server') {
      steps {
        echo '~~~~~~~~~~~send files to server~~~~~~~~~~~'
        // sh 'cp ./.env.sample ./.env' // create in ansible by jinja2
        sh 'scp -r ./* "$ANSIBLE_SERVER_USER"@"$ANSIBLE_SERVER_ADDR":"$ANSIBLE_SERVER_PATH"'
        // sh 'ssh "$ANSIBLE_SERVER_USER"@"$ANSIBLE_SERVER_ADDR" "docker-compose-restart node"'
        sh 'ansible-playbook -i webservers sendBackendData'
      }
    }
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Post actions~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  post {
    always {
      deleteDir()
    }
  }
}