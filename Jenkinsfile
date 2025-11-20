pipeline {
  agent any

  environment {
    ACR_NAME  = 'drakarionaksacr'
    ACR_LOGIN = 'drakarionaksacr.azurecr.io'
    WEB_IMAGE = "${ACR_LOGIN}/web"
    API_IMAGE = "${ACR_LOGIN}/api"
    IMAGE_TAG = "${env.BUILD_NUMBER}"

    // SonarCloud token из Credentials (Secret text, ID = sonarcloud-token)
    SONAR_TOKEN = credentials('sonarcloud-token')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Node tests (web & api)') {
      steps {
        dir('n-web') {
          sh '''
            npm ci
            npm run lint || true
            npm test || true
          '''
        }
        dir('n-api') {
          sh '''
            npm ci
            npm run lint || true
            npm test || true
          '''
        }
      }
    }

    stage('npm audit (security check)') {
      steps {
        dir('n-web') {
          sh '''
            echo "Running npm audit for n-web..."
            npm audit --audit-level=high || true
          '''
        }
        dir('n-api') {
          sh '''
            echo "Running npm audit for n-api..."
            npm audit --audit-level=high || true
          '''
        }
      }
    }

    stage('Helm & Terraform checks') {
      steps {
        sh '''
          # Helm lint
          helm lint charts/web   || true
          helm lint charts/api   || true
          helm lint charts/mysql || true

          # ===== mysql-helm-tf =====
          cd mysql-helm-tf
          terraform init -backend=false -input=false
          terraform fmt -check
          terraform validate || true

          # ===== app-helm-tf =====
          cd ../app-helm-tf
          terraform init -backend=false -input=false
          terraform fmt -check
          terraform validate || true
        '''
      }
    }

    stage('SonarCloud Analysis') {
      environment {
        SONAR_SCANNER_OPTS = '-Xmx512m'
      }
      steps {
        withSonarQubeEnv('sonarcloud') {
          script {
            // имя сканера должно совпадать с Global Tool Configuration
            def scannerHome = tool 'sonarscanner'

            sh """
              echo "Running SonarCloud analysis..."
              "${scannerHome}/bin/sonar-scanner" \
                -Dsonar.projectKey=aks-project \
                -Dsonar.organization=Drakarion \
                -Dsonar.sources=. \
                -Dsonar.exclusions=**/node_modules/**,**/charts/**,**/mysql-helm-tf/**,**/app-helm-tf/**,**/gitops/**
            """
          }
        }
      }
    }

    stage('Docker build & push') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'acr-drakarionaksacr',
            usernameVariable: 'ACR_USER',
            passwordVariable: 'ACR_PASS'
          )
        ]) {
          sh '''
            echo "$ACR_PASS" | docker login ${ACR_LOGIN} -u "$ACR_USER" --password-stdin

            docker build -t ${WEB_IMAGE}:${IMAGE_TAG} ./n-web
            docker build -t ${API_IMAGE}:${IMAGE_TAG} ./n-api

            docker push ${WEB_IMAGE}:${IMAGE_TAG}
            docker push ${API_IMAGE}:${IMAGE_TAG}

            docker logout ${ACR_LOGIN} || true
          '''
        }
      }
    }

    stage('Smoke test API container') {
      steps {
        sh '''
          echo "Starting API smoke test with image: ${API_IMAGE}:${IMAGE_TAG}"

          # Запускаем контейнер с API
          docker run -d --rm \
            --name api-smoke-test \
            -p 3000:3000 \
            ${API_IMAGE}:${IMAGE_TAG}

          echo "Waiting API to start..."
          sleep 15

          echo "Checking API health endpoint..."

          # 1-я попытка: /health
          if curl -f http://localhost:3000/health; then
            echo "API healthcheck /health OK"
          # 2-я попытка: корень /
          elif curl -f http://localhost:3000/; then
            echo "API healthcheck / OK"
          else
            echo "API smoke test FAILED"
            echo "=== API container logs ==="
            docker logs api-smoke-test || true
            docker stop api-smoke-test || true
            exit 1
          fi

          echo "Stopping API test container..."
          docker stop api-smoke-test || true
        '''
      }
    }

    stage('Update GitOps values (tags)') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'github-drakarion-token',
            usernameVariable: 'GIT_USER',
            passwordVariable: 'GIT_TOKEN'
          )
        ]) {
          sh '''
            git fetch origin
            git checkout -B main origin/main

            # Обновляем только values-файлы
            yq -i ".image.tag = \\"${IMAGE_TAG}\\"" gitops/values/web-values.yaml
            yq -i ".image.tag = \\"${IMAGE_TAG}\\"" gitops/values/api-values.yaml

            git config user.email "jenkins@local"
            git config user.name "jenkins-ci"

            git add gitops/values/web-values.yaml gitops/values/api-values.yaml
            git commit -m "Update images to tag ${IMAGE_TAG}" || echo "No changes to commit"

            # Пуш с токеном
            git push https://${GIT_USER}:${GIT_TOKEN}@github.com/Drakarion/AKS-group-project.git main
          '''
        }
      }
    }

  } // <-- конец блока stages
}   // <-- конец pipeline