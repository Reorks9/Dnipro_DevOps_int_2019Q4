pipeline {
  agent any
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/back-TODO.git"
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
        echo '~~~~~~~~~~~Cloning repo which include dockerfile and configs~~~~~~~~~~~'
        sshagent (credentials: ['ssh_key_for_github']) {
          sh 'git clone "$GIT_HUB_REPO" ./'
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~send files to web server~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('send files to server') {
      steps {
        echo '~~~~~~~~~~~send files to server~~~~~~~~~~~'
        sh 'cp ./.env.sample ./.env'
        sh 'scp -r ./* jenkins@192.168.0.115:/var/www/todo/back'
        sh 'ssh jenkins@192.168.0.115 "docker-compose-restart node"'
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