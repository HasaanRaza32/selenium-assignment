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
                    echo "Running lint..."
                    python3 -m pip install --user flake8 || true
                    ~/.local/bin/flake8 app || true
                '''
            }
        }

        stage('Build App Image') {
            steps {
                sh '''
                    echo "Building Flask app image..."
                    docker build -t selenium-app -f app/Dockerfile app/
                '''
            }
        }

        stage('Unit Testing') {
            steps {
                sh '''
                    echo "Running unit tests inside Docker..."

                    cat <<EOF > Dockerfile.tests
                    FROM python:3.10
                    WORKDIR /app
                    COPY . .
                    RUN pip install pytest flask requests
                    CMD ["pytest", "-q"]
                    EOF

                    docker build -t unit-tests -f Dockerfile.tests .
                    docker run --rm unit-tests
                '''
            }
        }

        stage('Containerized Deployment') {
            steps {
                sh '''
                    echo "Building Selenium test image..."
                    docker build -t selenium-tests -f selenium-test-docker/Dockerfile selenium-test-docker/
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
            echo "Pipeline completed."
        }
    }
}
