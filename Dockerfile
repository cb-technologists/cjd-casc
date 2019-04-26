FROM cloudbees/cloudbees-jenkins-distribution:2.164.2.1

LABEL maintainer "melgin@cloudbees.com"

USER root

ENV JENKINS_UC https://jenkins-updates.cloudbees.com
# add environment variable to point to configuration file
ENV CASC_JENKINS_CONFIG /usr/jenkins_config/jenkins-casc.yaml

# Install plugins
ADD https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh /usr/local/bin/install-plugins.sh
RUN chmod 755 /usr/local/bin/install-plugins.sh
ADD https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support /usr/local/bin/jenkins-support
RUN chmod 755 /usr/local/bin/jenkins-support
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/ref/plugins.txt)

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

USER jenkins