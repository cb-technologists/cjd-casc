pipeline {
  agent none
  environment {
    COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD')
  }
  stages {
    stage('Build and Push with Kaniko') {
      agent {
        kubernetes {
          label "kaniko-${UUID.randomUUID().toString()}"
          yaml """
kind: Pod
metadata:
  name: kaniko
spec:
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
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh """#!/busybox/sh
                /kaniko/executor --context `pwd` --destination mattelgin/cjd-casc:${env.COMMIT_ID}
          """
        }
      }
    }
    stage('Update CJD image') {
      agent {
        kubernetes {
          label "kubectl-${UUID.randomUUID().toString()}"
          yaml """
kind: Pod
metadata:
  name: kubectl
spec:
  containers:
  - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.11.2-bash
    imagePullPolicy: Always
    command:
    - cat
    tty: true
"""
        }
      }
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