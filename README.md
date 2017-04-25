# Create a self contained rails app in a container. All sources and bin are in
container, almost ready to run.


#------------------------
1) Copied existing Rails5 app (todo demo from https://medium.com/google-cloud/basic-rails-app-with-docker-a08eba3c2197)
as folder rails5-project-base/test

2) Modified config/database.yml:
  # per: https://blog.codeminer42.com/zero-to-up-and-running-a-rails-project-only-using-docker-20467e15f1be
development:
  <<: *default
  database: db/development_postgresql
  encoding: unicode
  host: db
  username: postgres
  password:

3) Added Dockerfile:

FROM miadocker/rails5-base:latest
MAINTAINER Ray Novarina <RNova94037@gmail.com>

# Define where our application will live inside the image
ENV RAILS_ROOT /app

RUN mkdir -p $RAILS_ROOT

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo "export PATH=$PATH" >> /root/.bashrc

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

#-------------------------------------------------------------------------------
# Finish establishing Rails app. Copy source, Gemfile. Bundle install em.

# Copy the Rails application, if any, into place
COPY . .

RUN bundle install

# Let the build process tell where gems were installed.
RUN bundle show coffee-rails

ENTRYPOINT ["bundle", "exec"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

4) Add docker-compose.yml:
version: "2"

services:
  web:
    build: .
    volumes:
      - .:/app
      - bundle_path:/bundle
    environment:
      - BUNDLE_PATH=/bundle/vendor
      - BUNDLE_APP_CONFIG=/app/.bundle
    command: bundle exec rails server -b 0.0.0.0
    ports:
      - "3000:3000"
    links:
      - db
    tty: true
    stdin_open: true

  db:
    image: postgres
    volumes:
      - db:/var/lib/postgresql/data
    expose:
      - '5432'

volumes:
  bundle_path:
  db:

5) Create database
$ docker-compose run --rm web bundle exec rake db:create
$ docker-compose run --rm web bundle exec rake db:migrate

6) Run app locally:
$ docker-compose up

7) Access via localhost:3000
