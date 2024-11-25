pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/VahantSharma/AutoDeployX.git'
            }
        }
        stage('Monitor Disk Utilization') {
            steps {
                script {
                    sh './disk.sh'
                }
            }
        }
        stage('Process Management') {
            steps {
                script {
                    sh './process.sh'
                }
            }
        }
    }
}

