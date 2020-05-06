#!/bin/bash
# This is runner Parkings-App 
# GIT:                   http://gitlab.telesoftmobile.com/parkings/parkings-app.git
# LINK:                  https://parkings.telesoftmobile.com/  
# IS STORED IN /opt/runner.sh and jenkins runs the script during every deployment 

service nginx start
service ssh start
service filebeat start

source  /opt/parkings/env/.env

mkdir  /tmp/pids
mkdir  /tmp/sockets

cd  /opt/parkings

bundle install --clean --deployment --without development test
yarn install
gem install rake -v "12.3.1"
rake assets:precompile
rake db:migrate

bundle exec unicorn_rails -c config/unicorn.rb -E production -p 3000 &
bundle exec sidekiq -d -e production