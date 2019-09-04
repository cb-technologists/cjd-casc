FROM cloudbees/cloudbees-jenkins-distribution:2.176.3.2 as war_source

FROM jenkins/jenkins:2.176.3

COPY --from=war_source /usr/share/cloudbees-jenkins-distribution/cloudbees-jenkins-distribution.war /usr/share/jenkins/jenkins.war

ENV JENKINS_UC https://jenkins-updates.cloudbees.com
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN bash /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt