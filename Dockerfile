# Dockerizing Mule EE
#FROM java:openjdk-8-jdk
FROM java:8
#FROM anapsix/alpine-java:8_jdk_nashorn

# Define environment variables.
CMD echo "------ Define Environment Variables --------"
ENV MULE_HOME /opt/mule
ENV MULE_VERSION 4.3.0-20210119

# Mule Runtime Setup
CMD echo "------ Download and Extract Mule Runtime --------"
RUN cd ~ && \
    wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz && \
    cd /opt && \
    tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz && \
	mv mule-standalone-${MULE_VERSION} mule && \
	rm ~/mule-standalone-${MULE_VERSION}.tar.gz && \
	chmod -R 777 /opt/mule

# Define mount points.
CMD echo "------ Define Mount Points --------"
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Copy and install license
CMD echo "------ Copy and Install License --------"
#COPY muleLicenseKey.lic ${MULE_HOME}/conf/
#RUN ${MULE_HOME}/bin/mule -installLicense ${MULE_HOME}/conf/muleLicenseKey.lic

# Deploy mule application
ARG JAR_FILE=*.jar
COPY ${JAR_FILE} ${MULE_HOME}/apps/

# Define working directory.
WORKDIR ${MULE_HOME}

# Port Exposed
EXPOSE 8081

# Start the mule runtime 
ENTRYPOINT ("./bin/mule")
