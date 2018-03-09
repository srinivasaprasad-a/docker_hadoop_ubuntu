#!/bin/bash

: ${HADOOP_PREFIX:=/programs/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh


# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml


service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

/bin/bash
