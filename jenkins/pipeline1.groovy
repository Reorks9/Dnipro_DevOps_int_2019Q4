pipeline {
  agent { 
    label 'docker' 
  }
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
      sh 'rm -rf *'
      sh 'rm -rf .git'
    }
  }
}

// sh "docker login --username=${DOCKER_HUB_LOGIN} --password=${DOCKER_HUB_PASS}"
// sh "build -f /home/arudy/docker/jenkins.Dockerfile -t ${DOCKER_HUB_LOGIN}/${DOCKER_REPO}:${IMAGE_NAME} ."
// sh "docker push ${DOCKER_HUB_LOGIN}/${DOCKER_REPO}:${IMAGE_NAME}"


// dockerfile
// Execute the Pipeline, or stage, with a container built from a Dockerfile contained in the source repository. In order to use this option, the Jenkinsfile must be loaded from either a Multibranch Pipeline or a Pipeline from SCM. Conventionally this is the Dockerfile in the root of the source repository: agent { dockerfile true }. If building a Dockerfile in another directory, use the dir option: agent { dockerfile { dir 'someSubDir' } }. If your Dockerfile has another name, you can specify the file name with the filename option. You can pass additional arguments to the docker build …​command with the additionalBuildArgs option, like agent { dockerfile { additionalBuildArgs '--build-arg foo=bar' } }. For example, a repository with the file build/Dockerfile.build, expecting a build argument version:

// agent {
//     // Equivalent to "docker build -f Dockerfile.build --build-arg version=1.0.2 ./build/
//     dockerfile {
//         filename 'Dockerfile.build'
//         dir 'build'
//         label 'my-defined-label'
//         additionalBuildArgs  '--build-arg version=1.0.2'
//         args '-v /tmp:/tmp'
//     }
// }
// dockerfile also optionally accepts a registryUrl and registryCredentialsId parameters which will help to specify the Docker Registry to use and its credentials. For example:

// agent {
//     dockerfile {
//         filename 'Dockerfile.build'
//         dir 'build'
//         label 'my-defined-label'
//         registryUrl 'https://myregistry.com/'
//         registryCredentialsId 'myPredefinedCredentialsInJenkins'
//     }
// }