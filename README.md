# Technical details
rails 5.2.1
ruby 2.5.1

# Installation
- git clone
- create `config/database.yml` from example
- create `.env` from example, don't forget to run `source env` after that
- `bundle install`
- rails db:create && rails db:migrate (ensure that postgres is installed)
- rails db:seed

# Tabulation
1 tab = 2 spaces

# How to create new api endpoint

- if controller method > 6 lines of code - move code to service / interaction / query object
- if controller method needs validation (can answer with 422 and errors) - create interaction
- if controller method doesn't need validation - create service
- if some code interacts with more than 1 model - create service
- if you have a fat query (with joins includes and so one) - create query objects

ps interaction - is cool thing that can
- keep application business logic inside
- validate api inputs
- respond with readable errors

# json generation
- we use active model serializers
- for api use `respond_with`, not `render`
- feel free to inherit serializers (they are like decorators)

# How to generate API docs
rake docs:update

# NOTES:
Dockerfile for creating docker image for each environment as well as nginx.conf and env files were moved to separate repo
```
http://gitlab.telesoftmobile.com/adig/parkings-app-env.git
```

# Yard Documentation

Feel free to read the raw comments on the project, but if you'd prefer a more pleasant reading, you can use our YARD documentation after the rails server start with ``` rails s``` You can access to it on this link
```
  http://localhost:8808
```
