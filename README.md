# bedrock_shiny_aws_docker
Version two of the bedrock shiny app deployed on AWS via docker

Real estate analysis using logistic linear regression and ordinary least squares regression.


Useful DOCKER COMMANDS
====================
1. to build an image
sudo docker build -t shiny_app .

2. to run container
sudo docker run --rm --user shiny -p 80:3838 bedrock_shiny_app

3. to check the history of the container
sudo docker history bedrock_shiny_app

4. to list all the available docker images on the host
sudo docker images -a

5. to list all the active docker images on the host
sudo docker ps

6. to remove a docker image
sudo docker rm -f <image id>

7. to remove all docker images from the current host
sudo docker system prune --all --force --volumes

8. to ssh into docker image:
    1. Find the image name using 
	      sudo docker ps
    2. access the terminal inside the image
	      sudo docker exec -it cranky_zhukovsky /bin/bash


