FROM cloudbees/cloudbees-jenkins-distribution:2.176.3.2

LABEL maintainer "melgin@cloudbees.com"

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER root

RUN echo 2.0 > /usr/share/cloudbees-jenkins-distribution/ref/jenkins.install.UpgradeWizard.state

ENV TZ="/usr/share/zoneinfo/America/New_York"

ENV JENKINS_UC https://jenkins-updates.cloudbees.com
# add environment variable to point to configuration file
ENV CASC_JENKINS_CONFIG /var/jenkins_config/jenkins-casc.yaml

# Install plugins
ADD https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh /usr/local/bin/install-plugins.sh
RUN sed -i 's:/usr/share/jenkins/jenkins.war:/usr/share/cloudbees-jenkins-distribution/cloudbees-jenkins-distribution.war:g' /usr/local/bin/install-plugins.sh
RUN sed -i 's:/usr/share/jenkins/ref/plugins:/usr/share/cloudbees-jenkins-distribution/ref/plugins:g' /usr/local/bin/install-plugins.sh
RUN chmod 755 /usr/local/bin/install-plugins.sh

ADD https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support /usr/local/bin/jenkins-support
RUN sed -i 's/rel="${b:23}"/rel="${b:46}"/g' /usr/local/bin/jenkins-support
RUN chmod 755 /usr/local/bin/jenkins-support

COPY plugins.txt /usr/share/cloudbees-jenkins-distribution/ref/plugins.txt
RUN bash /usr/local/bin/install-plugins.sh < /usr/share/cloudbees-jenkins-distribution/ref/plugins.txt

USER cloudbees-jenkins-distribution