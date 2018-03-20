FROM ubuntu:16.04
MAINTAINER SrinivasaPrasadA

USER root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk ssh curl

# Setup passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

WORKDIR /programs/
RUN pwd

ENV HADOOP_VERSION 2.9.0

RUN curl -fSL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz -o /programs/hadoop-$HADOOP_VERSION.tar.gz && \
    gunzip /programs/hadoop-$HADOOP_VERSION.tar.gz && \
    tar xf /programs/hadoop-$HADOOP_VERSION.tar && \
    mv /programs/hadoop-$HADOOP_VERSION /programs/hadoop && \
    rm /programs/hadoop-$HADOOP_VERSION.tar

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME
ENV HADOOP_PREFIX /programs/hadoop
ENV PATH $PATH:$HADOOP_PREFIX/bin

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport HADOOP_PREFIX=/programs/hadoop\nexport HADOOP_HOME=/programs/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/programs/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# Update HADOOP config files
ADD core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
ADD slaves $HADOOP_PREFIX/etc/hadoop/slaves

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_PREFIX/logs

RUN $HADOOP_PREFIX/bin/hdfs namenode -format

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config

RUN chmod +x $HADOOP_PREFIX/etc/hadoop/*-env.sh

ADD start_up.sh /etc/start_up.sh
RUN chown root:root /etc/start_up.sh && \
    chmod 700 /etc/start_up.sh

CMD ["/etc/start_up.sh", "-d"]
