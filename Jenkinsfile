#!groovy

def podLabel = "kaniko-${UUID.randomUUID().toString()}"

pipeline {
    agent {
        kubernetes {
            label podLabel
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
  labels:
    jenkins-build: app-build
    some-label: ""
spec:
  containers:
  - name: golang
    image: golang:1.11
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
      - name: go-build-cache
        mountPath: /root/.cache/go-build
      - name: img-build-cache
        mountPath: /root/.local
  volumes:
  - name: go-build-cache
    emptyDir: {}
  - name: img-build-cache
    emptyDir: {}
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: docker-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
"""
        }
    }

    environment {
        GITHUB_ACCESS_TOKEN  = credentials('github-token')
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/joostvdg/cat.git'
            }
        }
        stage('Build') {
            steps {
                container('golang') {
                    sh './build-go-bin.sh'
                }
            }
        }
        stage('Checkout Code') {
            steps {
              checkout scm
            }
        }

        stage('Build with Kaniko') {
          environment {
                PATH = "/busybox:$PATH"
          }
          steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              sh '''#!/busybox/sh
                  /kaniko/executor -f `pwd`/Dockerfile.run -c `pwd` --cache=true --verbosity debug --insecure --skip-tls-verify --destination internship/angular-app:v0.1.0 --destination internship/angular-app:latest
                '''
            }
          }
        }

    }
}
