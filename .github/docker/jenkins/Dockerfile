FROM jenkins/jenkins:lts-jdk11

COPY Jenkinsfile.dsl /Jenkinsfile.dsl
COPY configs/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY configs/jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dhudson.model.UsageStatistics.disabled=true"
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs

HEALTHCHECK --interval=10s --timeout=10s --start-period=30s CMD ["curl", "-sSf", "http://localhost:8080/login"]


