# docker_hadoop_ubuntu
To build Docker images for Hadoop on ubuntu image

This is single node hadoop installation with Namenode, Datanode, ResourceManager, NodeManager services on the same node.

Hadoop is 2.9.0 version

Ubuntu is 16.04 version

However above versions can be modified in Dockerfile and rebuild the image
Update the JAVA path in Dockerfile based on the default-jdk of the OS version

### Build
Run build.sh file to build the image

### Run
```docker run -i -t docker_hadoop_ubuntu:latest```