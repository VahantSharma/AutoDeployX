pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/VahantSharma/AutoDeployX.git'
            }
        }
        stage('Monitor Disk Utilization') {
            steps {
                script {
                    try {
                        sh './disk.sh'
                    } catch (Exception e) {
                        echo "Error in 'Monitor Disk Utilization' stage: ${e.getMessage()}"
                    }
                }
            }
        }
        stage('Process Management') {
            steps {
                script {
                    try {
                        sh './process.sh'
                    } catch (Exception e) {
                        echo "Error in 'Process Management' stage: ${e.getMessage()}"
                    }
                }
            }
        }
    }
}
