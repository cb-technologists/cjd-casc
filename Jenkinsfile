pipeline {
  agent none
  stages {
    stage('Build and push with kaniko') {
      agent {
        kubernetes {
          label "kaniko-${UUID.randomUUID().toString()}"
          yamlFile 'pod-templates/kanikoPod.yaml'
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
      when {
        beforeAgent true
        branch 'master'
      }
      agent {
        kubernetes {
          label "kubectl-${UUID.randomUUID().toString()}"
          yamlFile 'pod-templates/kubectlPod.yaml'
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