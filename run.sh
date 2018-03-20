sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                -p 50070:50070 \
                -p 8088:8088 \
                --name hadoop-master \
                --hostname hadoop-master \
		docker_hadoop_ubuntu:latest &> /dev/null


sudo docker rm -f hadoop-slave1 &> /dev/null
echo "start hadoop-slave1 container..."
sudo docker run -itd \
	        --name hadoop-slave1 \
	        --hostname hadoop-slave1 \
		docker_hadoop_ubuntu:latest &> /dev/null


sudo docker rm -f hadoop-slave2 &> /dev/null
echo "start hadoop-slave2 container..."
sudo docker run -itd \
	        --name hadoop-slave2 \
	        --hostname hadoop-slave2 \
		docker_hadoop_ubuntu:latest &> /dev/null


sudo docker exec -it hadoop-master bash
