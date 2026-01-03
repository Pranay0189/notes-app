pipeline {
    agent any

    environment {
        IMAGE_NAME = "notes-app"
        DOCKER_IMAGE = "pranay801/${IMAGE_NAME}:latest"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage ("checkout"){
            steps {
                git branch: 'main', url: ''
            }
        }

        stage ("docker login") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS' | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage ("build docker image") {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                '''
            }
        }

        stage ("trivy image scan") {
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}:{IMAGE_TAG}
                '''
            }
        }

        stage ("push docker image") {
            steps {
                sh '''
                    docker push -t ${DOCKER_IMAGE}:${IMAGE_TAG}
                '''
            }
        }
    }
}