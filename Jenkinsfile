#!groovy

def podLabel = "kaniko-${UUID.randomUUID().toString()}"

pipeline {
    agent {
        kubernetes {
            label podLabel
            defaultContainer 'jnlp'
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-build: app-build
    some-label: ""
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    imagePullPolicy: IfNotPresent
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: docker-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
'''
        }
    }

    environment {
        GITHUB_ACCESS_TOKEN  = credentials('github-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
              checkout scm
            }
        }

        stage('Build with Kaniko') {
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              withEnv(['PATH+EXTRA=/busybox']) {
                sh '''#!/busybox/sh -xe
                  /kaniko/executor \
                    --dockerfile Dockerfile \
                    --context `pwd`/ \
                    --verbosity debug \
                    --insecure \
                    --skip-tls-verify \
                    --destination dockername/angular-app:v0.1.0 \
                    --destination dockername/angular-app:latest
                '''
              }
            }
          }
        }

    }
}
