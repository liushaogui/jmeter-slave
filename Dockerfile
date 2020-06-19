# oracle jdk 1.8 备用
#FROM runcare/debian-jre1.8

# openjdk 1.8
FROM runcare/openjdk-jre1.8

# 更新版本1
MAINTAINER runcare<larrygui@foxmail.com>

ARG JMETER_VERSION="5.1.1"
ENV JMETER_HOME /opt/apache-jmeter-$JMETER_VERSION
ENV JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz
ENV SSL_DISABLED true

RUN mkdir -p /tmp/dependencies  \
	&& curl -L --silent $JMETER_DOWNLOAD_URL >  /tmp/dependencies/apache-jmeter-$JMETER_VERSION.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-$JMETER_VERSION.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# TODO: plugins (later)
# && unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME

WORKDIR	$JMETER_HOME

RUN sed 's/#beanshell.server.port=9000/beanshell.server.port=9000/g' ./bin/jmeter.properties > ./bin/jmeter_temp.properties
RUN mv ./bin/jmeter_temp.properties ./bin/jmeter.properties

COPY update_parameter.bsh $JMETER_HOME

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_HOME/bin

VOLUME ["/data"]

EXPOSE 1099 60001

ENTRYPOINT jmeter-server -Dserver.rmi.localport=60001 -Dserver_port=1099 \
            -Jserver.rmi.ssl.disable=$SSL_DISABLED
