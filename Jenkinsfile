pipeline {
    agent any

    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-credentials')
        BRANCH_NAME = "${GIT_BRANCH.split('/').size() > 1 ? GIT_BRANCH.split('/')[1..-1].join('/') : GIT_BRANCH}"
        MINIO_CREDS = credentials('minio-credentials')
        MINIO_HOST = "https://minio.rabbahsoft.ma:9900"
    }
    stages {
        stage('Test') {
            agent {
                docker {
                  image 'node:16.16.0'
                  reuseNode true
                }
            }
            steps {
                //sh 'git reset --hard  && git clean -fdx --exclude="/node_modules/"'
                sh 'yarn install'
                sh 'yarn test:unit'
            }
        }
         
         
        stage('Build') {
            agent {
                docker {
                  image 'node:16.16.0'
                  reuseNode true
                }
            }
            steps {
              sh 'yarn build'
            }
        }
        stage('Publish') {
            agent {
                docker {
                    image 'mrabbah/mc:1.1'
                    reuseNode true
                }
            }
            steps {
              sh 'mc --config-dir /tmp/.mc alias set minio $MINIO_HOST $MINIO_CREDS_USR $MINIO_CREDS_PSW'
              sh 'cd dist && tar -czf ../corteza-webapp-workflow-${BRANCH_NAME}.tar.gz .'
              sh 'mc --config-dir /tmp/.mc cp ./corteza-webapp-workflow-${BRANCH_NAME}.tar.gz minio/corteza-artifacts'
            }
        }
        stage('Build Docker image') {

            steps {
                sh 'docker build -t mrabbah/corteza-webapp-workflow:${BRANCH_NAME} --build-arg VERSION=${BRANCH_NAME} . '
            }
        }

        stage('Push Docker image') {

            steps {
                echo 'Pushing docker image'
                script {
                    sh 'echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin'
                    sh 'docker push mrabbah/corteza-webapp-workflow:${BRANCH_NAME}'
                }

            }
        }

        stage('Deploy') {

            steps {
                script {
                    sh 'sed -i "s/TAG_NAME/${BRANCH_NAME}/g" ./k8s/deployment-dev.yml'
                    sh 'curl -LO "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl"'
                    sh 'chmod u+x ./kubectl'
                    withKubeConfig([credentialsId: 'k8s-token', serverUrl: 'https://rancher.rabbahsoft.ma/k8s/clusters/c-m-6mdv2kbw']) {
                        sh './kubectl apply -f k8s/deployment-dev.yml'
                    }
                }

            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }

}
