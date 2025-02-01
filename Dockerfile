# Базовый образ с JAVA
FROM debian:bookworm AS java-base

ENV JAVA_DISTR=https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jdk_x64_linux_8u232b09.tar.gz
ENV TZ=Europe/Moscow

RUN apt update \
&& apt upgrade -y \
&& apt install wget -y \
&& wget ${JAVA_DISTR}  -O java.tar.gz \
&& mkdir /usr/lib/default-java \
&& tar zxvf java.tar.gz -C /usr/lib/default-java \
&& rm -f java.tar.gz \
&& ln -s /usr/lib/default-java/openjdk-8u232-b09 /usr/lib/java

ENV JAVA_HOME="/usr/lib/java"
ENV JRE_HOME="$JAVA_HOME/jre"
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV JAVA_OPTS=""

#Установка CSP 
FROM java-base AS csp-java

COPY ./jcp-2.0.41789.zip .

RUN apt install unzip -y \
&& unzip jcp-2.0.41789.zip -d /opt\
&& cd /opt/jcp-2.0.41789 \
&& java -cp .:*: ru.CryptoPro.Installer.InstallerConsole $JAVA_HOME -force -install -jre $JRE_HOME -jcp -jcryptop 

#Установка доп библиотек для смэв
FROM java-base AS smev-java 

RUN wget https://repo1.maven.org/maven2/commons-logging/commons-logging/1.1/commons-logging-1.1.jar -P /usr/lib/java/jre/lib/ext/ \
&& wget https://repo1.maven.org/maven2/org/apache/santuario/xmlsec/1.4.5/xmlsec-1.4.5.jar -P /usr/lib/java/jre/lib/ext/

#Сборка смэв агента
FROM java-base

ENV ADAPTER_DIR=

ENV DBHOST=""
ENV DBPORT=""
ENV DBNAME=""
ENV DBUSER=""
ENV DBPASS=""

COPY --from=smev-java /usr/lib/java/jre/lib/ext/*.jar /usr/lib/java/jre/lib/ext/

COPY --from=csp-java /usr/lib/java/jre/lib/security/java.security /usr/lib/java/jre/lib/security/java.security
COPY --from=csp-java /usr/lib/java/jre/lib/ext/* /usr/lib/java/jre/lib/ext/
COPY --from=csp-java /var/opt/cprocsp /var/opt/cprocsp

RUN useradd smev -d /home/smev -b /home/smev -m \
&& wget https://info.gosuslugi.ru/download.php?id=5586 -O ~/adapter_install.run  \
&& chmod +x ~/adapter_install.run \
&& cd && bash ~/adapter_install.run || true \
&& mv ~/bpm-service-unixbuild /opt/adapter 

COPY ./entrypoint.sh /opt/adapter
RUN chown -R smev:smev /opt/adapter 

USER smev
WORKDIR /opt/adapter
RUN mkdir /opt/adapter/in

ENTRYPOINT [ "/bin/bash", "-x", "entrypoint.sh" ]
