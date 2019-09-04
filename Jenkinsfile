pipeline {
  agent none
  stages {
    stage('Build and push with kaniko') {
      agent {
        kubernetes {
          label "kaniko"
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
    stage('Deploy to Staging') {
      when {
        beforeAgent true
        branch 'staging'
      }
      agent {
        kubernetes {
          label "kubectl"
          yamlFile 'pod-templates/kubectlPod.yaml'
        }
      }
      steps {
        container('kubectl') {
          sh """
            kubectl -n cjd-staging apply -f jenkinsCascStaging.yaml
            kubectl -n cjd-staging apply -f cjdStaging.yaml
            kubectl -n cjd-staging set image statefulset cjd cjd=gcr.io/melgin/cjd-casc:${env.COMMIT_ID}
          """
        }
        echo "Staging environment available at http://cjd-staging.cloudbees.elgin.io"
        input message: "Approve update?"
      }
      post {
        always {
          container('kubectl') {
            sh "kubectl -n cjd-staging delete sts,svc,ing cjd"
          }
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
          label "kubectl"
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