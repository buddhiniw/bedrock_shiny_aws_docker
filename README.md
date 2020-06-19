<<<<<<< HEAD
bedrock_shiny_aws_docker

Version two of the bedrock shiny app deployed on AWS via docker

Real estate analysis using logistic linear regression and ordinary least squares regression.


# INSTRUCTIONS TO MAKE DOCKER IMAGE OF THE SHINY APP
# ===================================================

Main Directory
	--- shiny_app
	--- Dockerfile

1. Make Dockerfile
	e.g file
	https://github.com/buddhiniw/aws_shiny_docker/blob/master/docker_shiny_app/Dockerfile

2. Compile and create docker image by running this inside the Main directory. Image is created on the home folder.
	sudo docker build -t bedrock_app .


# INSTRUCTIONS TO RUN SHINY APP DOCKER IMAGE ON AWS
# ==================================================

1. To run the app on local machine
	sudo docker run  --user shiny --rm -p 80:3838 bedrock_app


 # INSTRUCTIONS TO RUN SHINY APP DOCKER IMAGE ON AWS
 # ==================================================

1. save your Docker Image as a tar-archive
	sudo docker save -o ~/bedrock_app.tar bedrock_app

2. copy the tar file of the image to AWS from the AWS key folder
	sudo scp -i <path-to-aws key> /home/buddhini/bedrock_app.tar ubuntu@ec2-18-222-199-23.us-east-2.compute.amazonaws.com:.

3. Log into AWS machine:
	ssh -i AWS_key/ec2-rshiny-reg.pem ubuntu@ec2-18-191-172-26.us-east-2.compute.amazonaws.com

4. Load the app
	sudo docker load -i bedrock_app.tar 
		
5. Make sure shiny server is running by going to website and opening
	http://18.191.172.70:3838/   (or the public DNS of your AWS instance)
	If not restart shiny server

6. run the docker image such that shiny server is running on port 80

	sudo docker run --user shiny -p 80:3838 bedrock_app

7. Open the app on chrome	
	http://18.191.172.26/
	
### NOTE - file write permission issues on the docker container was resolved by creating a group shiny-group and giving the group rwx to the /srv/shiny-server (see the Docker file for instructions). Then user shiny was added to the shin-group. This allows shiny to rwx on the /srv/shiny-server during the intermediate steps for crating pdf and html files.

### BUT If there is an error in file write permision, log into the container and check rw permission on server. The docker file is set to give permission to shiny to rwx on the /srv/shiny-server folder but just in case if it doesnt work do following:

	 sudo docker ps
	 sudo docker exec -it happy_wozniak /bin/bash
	 	root@0250a115f061:/srv/shiny-server# ls -lrt		
		chgrp shiny-group /srv/shiny-server/*



# HOWTO SETUP SHINY & DOCKER ON AWS
# ============================================

Log into AWS instance
	ssh -i AWS_key/ec2-rshiny-reg.pem ubuntu@ec2-18-217-143-145.us-east-2.compute.amazonaws.com

## installing R
sudo apt-get update
sudo apt-get -y install r-base

## R studio:
$ sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

64bit
Size:  58.5 MB MD5: 14b591d77b51cfe1fc38168d332ea0ea Version:  1.5.9.923 Released:  2018-09-11
	sudo apt-get install gdebi-core
	wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
	sudo gdebi shiny-server-1.5.9.923-amd64.deb


Check if shiny server is working:
http://13.58.166.235:3838/ (public dns:3838)


## Install Docker:
sudo snap install docker





# USEFUL DOCKER COMMANDS
# ====================
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




=======
# analytics_ecommerce
>>>>>>> 02dabf16a1686b0a712050288a16bc888638c0f2
