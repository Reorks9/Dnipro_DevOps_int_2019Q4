pipeline {
  agent { 
    label 'docker' 
  }
  environment {
    GIT_HUB_USER_NAME   = "studentota2lvl"
    GIT_HUB_USER_EMAIL  = "studentota2lvl@gmail.com"
    GIT_HUB_REPO        = "git@github.com:studentota2lvl/Dnipro_DevOps_int_2019Q4.git"
    registry            = "${GIT_HUB_USER_NAME}/jenkins"
    IMAGE_NAME          = "jenkinsNginx"
    DOCKER_HUB_REPO     = "${IMAGE_NAME}"
    jenkinsImage        = ''
    dockerfile          = "dockerfile"
    jenkinsCreds        = credentials('jenkins_credentials')
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~Test image~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    stage('Test') {
      steps {
        echo '~~~~~~~~~~~test image~~~~~~~~~~~'
        script {
          sh 'docker run -d -t -p 17000:8081 --name jenkins ${registry}:${BUILD_ID}'
          sh 'sleep 40'
          def responce = sh (returnStdout: true, script: 'docker exec --tty jenkins /usr/bin/wget localhost:8081 --http-user=${jenkinsCreds_USR} --http-password=${jenkinsCreds_PSW} --auth-no-challenge --server-response 2>&1 | grep -c "200 OK"').trim()
          echo "${responce}"
        }
      }
    }  
// // + wget 0.0.0.0:8081 --user=**** --password=**** --auth-no-challenge --server-response
// // --2020-02-12 07:01:47--  http://0.0.0.0:8081/
// // Connecting to 0.0.0.0:8081... failed: Connection refused.
//     stage('Test') {
//       steps {
//         echo '~~~~~~~~~~~test image~~~~~~~~~~~'
//         script {
//           jenkinsImage.inside('-p 17000:8081') {
//             sh 'echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"'
//             sh 'sleep 40'
//             def responce = sh (returnStdout: true, script: 'wget 127.0.0.1:8081 --user=arudy --password=arudy --auth-no-challenge --server-response 2>&1').trim()
//             sh 'sleep 10'
//           }
//         }
//         echo '${responce}'
//       }
//     }
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
      sh '(docker kill jenkins && docker container rm jenkins) || docker container rm jenkins'
    }
  }
}