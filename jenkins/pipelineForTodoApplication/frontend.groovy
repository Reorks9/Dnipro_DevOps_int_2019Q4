pipeline {
  agent { 
    label 'docker' 
  }
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/front-TODO.git"
    WEB_SERVER_PATH  = "jenkins@192.168.0.115:/var/www/todo/front"
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Install app~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stages {
    stage('build app env') {
      steps{
        echo '~~~~~~~~~~~Install git variables~~~~~~~~~~~'
        sh 'git config --global user.name "$GIT_HUB_USER_NAME"'
        sh 'git config --global user.email "$GIT_HUB_USER_EMAIL"'
        sh 'mkdir -p ~/.ssh'
        sh 'ssh-keyscan "github.com">> ~/.ssh/known_hosts'
      }
    }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Clone repo~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Repo cloning') {
      steps {
        echo '~~~~~~~~~~~Cloning repo~~~~~~~~~~~'
        sshagent (credentials: ['ssh_key_for_github']) {
          sh 'git clone "$GIT_HUB_REPO" ./'
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~build angular app~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('build angular app') {
      steps {
        echo '~~~~~~~~~~~build angular app~~~~~~~~~~~'
        script {
          docker.image('node').inside('-v .:/home/node/app') {
            sh 'cp ./src/environments/environment.ts ./src/environments/environment.dev.ts'
            sh 'npm Install'
            sh 'cd /home/node/app && npm build:dev'
          }
        }
      }  
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~send files to web server~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('send files to server') {
      steps {
        echo '~~~~~~~~~~~send files to server~~~~~~~~~~~'
        sh 'scp -r ./dist/* "$WEB_SERVER_PATH'
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