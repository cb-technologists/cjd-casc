pipeline {
  agent none
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
  serviceAccountName: cjd
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
        container('jnlp') {
          script {
              env.COMMIT_ID = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
          }
        }
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh """#!/busybox/sh
                /kaniko/executor --context `pwd` --destination mattelgin/cjd-casc:${env.COMMIT_ID} --cache=true
          """
        }
      }
    }
    stage('Update CJD') {
      agent {
        kubernetes {
          label "kubectl-${UUID.randomUUID().toString()}"
          yaml """
kind: Pod
metadata:
  name: kubectl
spec:
  serviceAccountName: cjd
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
            kubectl apply -f jenkinsCasc.yaml
            kubectl apply -f cjd.yaml
            kubectl set image statefulset cjd cjd=mattelgin/cjd-casc:${env.COMMIT_ID}
          """
        }
      }
    }
  }
}