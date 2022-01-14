@Library('pipeline-library-demo')_
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sayHello 'Dave'
            }
        }
        stage('Checkout') {
            steps {
                checkoutstep 'https://github.com/amitvermaa93/jenkins-git-integration.git'
            }
        }
        stage('print') {
            steps {
                sh 'ls'
            }
        }
        stage('build') {
            steps {
                sh "mvn clean verify"
            }
        }
    }
}
