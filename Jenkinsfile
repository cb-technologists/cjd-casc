pipeline {
  agent {
        kubernetes {
          label "kaniko-kubectl-${UUID.randomUUID().toString()}"
          yaml """
kind: Pod
metadata:
  name: kaniko-kubectl
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.11.2-bash
    imagePullPolicy: Always
    command:
    - cat
    tty: true
  volumes:
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
  stages {
    stage('Build and Push with Kaniko') {
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        container('jnlp') {
          script {
              env.COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD')
          }
        }
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh """#!/busybox/sh
                /kaniko/executor --context `pwd` --destination mattelgin/cjd-casc:${env.COMMIT_ID}
          """
        }
      }
    }
    stage('Update CJD image') {
      steps {
        container('kubectl') {
          sh """
            kubectl -n cjd patch statefulset cjd -p '{"spec":{"containers":[{"name":"cjd","image":"mattelgin/cjd-casc:${env.COMMIT_ID}"}]}}'
          """
        }
      }
    }
  }
}