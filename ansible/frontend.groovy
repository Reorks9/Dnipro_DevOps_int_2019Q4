pipeline {
  agent { 
    label 'docker' 
  }
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/front-TODO.git"
   // ANSIBLE_SERVER_PATH  = "jenkins@192.168.0.115:/var/www/todo/front"
    ANSIBLE_SERVER_USER = "jenkins"
    ANSIBLE_SERVER_ADDR = "192.168.0.115" // static ansible server ip
    ANSIBLE_SERVER_PATH = "~/todo/front"
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
        //ssh keyscan for own ansible server&&&&&&&
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
// проверить билдится ли оно вовсе в контейнере.. нет ли проблем с энв и прочей хуетой
    stage('build angular app') {
      steps {
        echo '~~~~~~~~~~~build angular app~~~~~~~~~~~'
        sh 'cp .хз где.. ещ что было скопировано ансиблом environment.ts ./src/environments/environment.dev.ts'
        script {
          docker.image('node').inside('-v .:/home/node/app') {
            sh 'npm Install'
            sh 'cd /home/node/app && npm run build:dev'
          }
        }
      }  
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~send files to web server~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('send files to server') {
      steps {
        echo '~~~~~~~~~~~send files to server~~~~~~~~~~~'
        sh 'scp -r ./dist/* "$ANSIBLE_SERVER_USER@$ANSIBLE_SERVER_ADDR:$ANSIBLE_SERVER_PATH"'
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