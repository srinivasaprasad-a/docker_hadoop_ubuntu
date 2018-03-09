FROM ubuntu:16.04
MAINTAINER SrinivasaPrasadA

USER root

# Install default JDK of the OS and SSH
RUN apt-get update && \
    apt-get install -y default-jdk && \
    apt-get install -y ssh

# Setup passwordless ssh
RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# Setup working directory
WORKDIR /programs/
RUN pwd

# Setup java path
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64 \
    PATH $PATH:$JAVA_HOME

# Download and decompress hadoop
RUN wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz -P /programs/ && \
    gunzip /programs/hadoop-2.9.0.tar.gz && \
    tar xf /programs/hadoop-2.9.0.tar && \
    mv /programs/hadoop-2.9.0 /programs/hadoop && \
    rm /programs/hadoop-2.9.0.tar

# Setup hadoop path
ENV HADOOP_PREFIX /programs/hadoop

# Add configurations to hadoop-env.sh
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport HADOOP_PREFIX=/programs/hadoop\nexport HADOOP_HOME=/programs/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/programs/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# Backup default config files
RUN mkdir $HADOOP_PREFIX/backup && \
    cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/backup

# Update config files
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml

ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

# Format namenode to start fresh
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# ssh config changes
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config

RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config && \
    echo "Port 2122" >> /etc/ssh/sshd_config

# bootstrap bash script to be executed once container starts
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && \
    chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

# Add execute privileges
RUN chmod +x $HADOOP_PREFIX/etc/hadoop/*-env.sh

RUN service ssh start && \
    $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    $HADOOP_PREFIX/sbin/start-dfs.sh && \
    $HADOOP_PREFIX/sbin/start-yarn.sh

# Execute bootstrap.sh on container start
CMD ["/etc/bootstrap.sh", "-d"]

# Expose these ports
EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030
