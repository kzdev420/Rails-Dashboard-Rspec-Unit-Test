# Base docker image for Parkings-App
# 
# docker build -t telesoft-parkings-app-base:latest .
# docker tag telesoft-parkings-app-base:latest telesoftdevops/devops:telesoft-parkings-app-base
# docker push telesoftdevops/devops:telesoft-parkings-app-base

FROM ruby:2.5 

RUN set -ex \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list \
  && wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y nodejs yarn nginx ssh vim apt-transport-https filebeat \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && rm /etc/nginx/sites-enabled/default* \
  && rm /etc/filebeat/filebeat.yml \
  && echo done!

COPY filebeat.yml /etc/filebeat/filebeat.yml