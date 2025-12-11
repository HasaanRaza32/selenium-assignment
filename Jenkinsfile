pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Code Linting') {
            steps {
                sh '''
                    echo "Running linting..."
                    python3 -m pip install --user flake8 || true
                    ~/.local/bin/flake8 app || true
                '''
            }
        }

        stage('Build App') {
            steps {
                sh '''
                    echo "Building application..."
                    docker build -t selenium-app ./app
                '''
            }
        }

        stage('Unit Testing') {
            steps {
                sh '''
                    echo "Running unit tests..."
                    python3 -m pip install --user pytest || true
                    pytest -q || true
                '''
            }
        }

        stage('Containerized Deployment') {
            steps {
                sh '''
                    echo "Building Selenium test container..."
                    docker build -t selenium-tests .
                '''
            }
        }

        stage('Selenium Testing') {
            steps {
                sh '''
                    echo "Running Selenium tests..."
                    docker run --rm selenium-tests
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
