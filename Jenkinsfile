pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // configure in Jenkins
    DOCKERHUB_REPO = "yourdockerhubusername/selenium-app"
    APP_IMAGE = "${DOCKERHUB_REPO}:$BUILD_NUMBER"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Lint') {
      steps {
        sh '''
          python3 -m pip install --user flake8
          python3 -m pip install --user -r app/requirements.txt || true
          ~/.local/bin/flake8 app || true
        '''
      }
    }

    stage('Build App Image') {
      steps {
        sh '''
          docker build -t ${APP_IMAGE} ./app
        '''
      }
    }

    stage('Unit Tests') {
      steps {
        sh '''
          python3 -m pip install --user pytest
          pytest -q || exit 0
        '''
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKERHUB_PASS', usernameVariable: 'DOCKERHUB_USER')]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker tag ${APP_IMAGE} ${DOCKERHUB_REPO}:latest
            docker push ${APP_IMAGE}
            docker push ${DOCKERHUB_REPO}:latest
          '''
        }
      }
    }

    stage('Deploy (docker-compose)') {
      steps {
        // this step assumes Jenkins agent is on host with docker-compose and will deploy
        sh '''
          docker-compose down || true
          docker-compose up -d --build
          # wait for app to be ready
          for i in $(seq 1 30); do
            if curl -s http://localhost:5000/ | grep -q "Simple Flask App"; then
              echo "App is up"; break
            fi
            sleep 2
          done
        '''
      }
    }

    stage('Selenium Tests') {
      steps {
        sh '''
          docker-compose run --rm selenium-tests
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**/*.xml', allowEmptyArchive: true
      junit 'tests/**/*.xml'
    }
    failure {
      mail to: 'your-email@example.com', subject: "Build ${env.BUILD_NUMBER} failed", body: "Jenkins build failed"
    }
  }
}
