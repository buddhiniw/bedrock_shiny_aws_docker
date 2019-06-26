FROM rocker/shiny:latest AS build
ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/

MAINTAINER Buddhini Waidyawansa (buddhiniw@gmail.com)

# Install tools required for project - R dependancies for Ubuntu
RUN apt-get update && apt-get install -y \
    sudo \
    libxt-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev


# Install R packages from CRAN required to run the elnet app
RUN Rscript -e "install.packages(c('shiny','shinydashboard','dplyr','shinythemes','caret','broom','glmnet','DMwR','elasticnet','corrplot','officer','xml2','openssl','httr','rvest','latexpdf','kableExtra','prettyR','tinytex','DT'), repos='https://cran.cnr.berkeley.edu/')"\
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# https://cloud.r-project.org/

# Install tinyTex
RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  ## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
  && R -e "tinytex::install_tinytex(dir = '/opt/TinyTeX')" \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install metafont mfware inconsolata tex ae parskip listings \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin


# Make the ShinyApp available at port 80 to allow access from outside of the container to the container service
# at the ports to allow access from firewall if accessing from outside the server. 
EXPOSE 80


# copy the app codes from the host (relative path to the Dockerfile) to /srv/shiny-server in the container
COPY shiny_app /srv/shiny-server/

# Make all app files readable
RUN chmod -R +r /srv/shiny-server/

# Set the working directory inthe server
WORKDIR /srv/shiny-server

# Make group shiny-group and add user shiny to shiny-group
RUN addgroup shiny-group 
RUN adduser shiny shiny-group	

# Change group of shiny server and subfiles to shiny-group
RUN chgrp shiny-group /srv/shiny-server
RUN chgrp shiny-group /srv/shiny-server/*

# Give the group rwx access 
RUN chmod g+rwx  /srv/shiny-server
RUN chmod g+rwx  /srv/shiny-server/*

