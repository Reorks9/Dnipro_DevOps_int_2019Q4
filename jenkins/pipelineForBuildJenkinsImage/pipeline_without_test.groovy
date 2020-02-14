pipeline {
  agent { 
    label 'docker' 
  }
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/Dnipro_DevOps_int_2019Q4.git"
    registry            = "${GIT_HUB_USER_NAME}/jenkins"
    IMAGE_NAME          = "jenkinsMavenNginx"
    DOCKER_HUB_REPO     = "${IMAGE_NAME}"
    jenkinsImage        = ''
    dockerfile          = "dockerfile"
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Install app~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stages {
    stage('Environment preconfiguration') {
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
        echo '~~~~~~~~~~~Cloning repo which include dockerfile and configs~~~~~~~~~~~'
        sshagent (credentials: ['ssh_key_for_github']) {
          sh 'git clone "$GIT_HUB_REPO" ./'
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Create docker image~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Build image') {
      steps {
        echo '~~~~~~~~~~~Starting to build jenkins image~~~~~~~~~~~'
        sh 'cp -r ./Docker/docker/* .'
        script {
          jenkinsImage = docker.build("${registry}:${env.BUILD_ID}", "-f ./${dockerfile} . ") // hardcode
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Push image~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Deploy Image') {
      steps{
        echo '~~~~~~~~~~~Deploy image to docker hub~~~~~~~~~~~'
        script {
          docker.withRegistry( '', 'docker_credentials' ) {
            jenkinsImage.push("ubuntu-${env.BUILD_NUMBER}")
            jenkinsImage.push("ubuntu-latest")
          }
        }
      }
    }
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Post actions~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  post {
    always {
      sh 'rm -rf *'
      sh 'rm -rf .git'
    }
  }
}