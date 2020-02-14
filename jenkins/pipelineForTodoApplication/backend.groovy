pipeline {
  agent any
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/back-TODO.git"
    WEB_SERVER_USER     = "jenkins"
    WEB_SERVER_ADDR     = "192.168.0.115"
    WEB_SERVER_PATH     = "/var/www/todo/back"
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
        sh 'cp ./.env.sample ./.env'
        sh 'scp -r ./* "$WEB_SERVER_USER"@"$WEB_SERVER_ADDR":"$WEB_SERVER_PATH"'
        sh 'ssh "$WEB_SERVER_USER"@"$WEB_SERVER_ADDR" "docker-compose-restart node"'
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