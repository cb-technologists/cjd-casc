pipeline {
  agent none
  stages {
    stage('Build and push with kaniko') {
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
    image: gcr.io/kaniko-project/executor:debug-v0.10.0
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
          name: gcr-secret
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
                /kaniko/executor --context `pwd` --destination gcr.io/melgin/cjd-casc:${env.COMMIT_ID} --cache=true
          """
        }
      }
    }
    stage('Update CJD') {
      // when {
      //   beforeAgent true
      //   branch 'master'
      // }
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
    image: gcr.io/cloud-builders/kubectl@sha256:50de93675e6a9e121aad953658b537d01464cba0e4a3c648dbfc89241bb2085e
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
            kubectl set image statefulset cjd cjd=gcr.io/melgin/cjd-casc:${env.COMMIT_ID}
          """
        }
      }
    }
  }
}