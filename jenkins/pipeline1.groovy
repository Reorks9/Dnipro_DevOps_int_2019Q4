pipeline {
  agent any
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/Dnipro_DevOps_int_2019Q4.git"
    registry            = "${GIT_HUB_USER_NAME}/jenkins"
    DOCKER_HUB_CREDS    = credentials('docker_credentials')
    IMAGE_NAME          = "jenkinsMavenNginx"
    DOCKER_HUB_REPO     = "${IMAGE_NAME}"
    jenkinsImage        = ''
    dockerfile          = "jenkins.Dockerfile"
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Install app~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stages {
    stage('Environment preconfiguration') {
      steps{
        echo '~~~~~~~~~~~Install git variables~~~~~~~~~~~'
        sh 'git config --global user.name "$GIT_HUB_USER_NAME"'
        sh 'git config --global user.email "$GIT_HUB_USER_EMAIL"'
        sh 'ssh-keyscan "github.com"> ~/.ssh/known_hosts 2>/dev/null'
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
        script {
          jenkinsImage = docker.build("${registry}:${env.BUILD_ID}", "-f ./jenkins/${dockerfile} . ") // hardcode
        }
      }
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Push image~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Deploy Image') {
      steps{
        echo '~~~~~~~~~~~Deploy image to docker hub~~~~~~~~~~~'
        script {
          docker.withRegistry( '', DOCKER_HUB_CREDS ) {
            jenkinsImage.push('latest')
          }
        }
      }
    }
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Post actions~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  post {
    always {
      sh 'ls -al'
      sh 'rm -rf *'
      sh 'rm -rf .git'
      sh 'ls -al'
    }
  }
}

// sh "docker login --username=${DOCKER_HUB_LOGIN} --password=${DOCKER_HUB_PASS}"
// sh "build -f /home/arudy/docker/jenkins.Dockerfile -t ${DOCKER_HUB_LOGIN}/${DOCKER_REPO}:${IMAGE_NAME} ."
// sh "docker push ${DOCKER_HUB_LOGIN}/${DOCKER_REPO}:${IMAGE_NAME}"