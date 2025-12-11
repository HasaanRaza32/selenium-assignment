pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t selenium-tests .'
            }
        }

        stage('Run Selenium Tests') {
            steps {
                echo "Running tests inside Docker container..."
                sh 'docker run --rm selenium-tests'
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed! Check the logs for details."
        }
    }
}
