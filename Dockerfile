
# influenced by:
#   https://hub.docker.com/r/bartoffw/rails5/~/dockerfile/
#   https://github.com/docker/docker/issues/30441
#   https://nickjanetakis.com/blog/dockerize-a-rails-5-postgres-redis-sidekiq-action-cable-app-with-docker-compose
#   https://github.com/philou/planning-poker.git
#-------------------------------------------------------------------------------

FROM miadocker/rails5-base:latest
MAINTAINER Ray Novarina <RNova94037@gmail.com>

# Define where our application will live inside the image
ENV RAILS_ROOT /app

#RUN useradd -m -s /bin/bash -u 1000 railsuser
#user railsuser

RUN mkdir -p $RAILS_ROOT

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo "export PATH=$PATH" >> /root/.bashrc

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

#-------------------------------------------------------------------------------
# Finish establishing Rails app. Copy source, Gemfile. Bundle install em.

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/

# Copy the Rails application, if any, into place
COPY . .

RUN bundle install

# Let the build process tell where gems were installed.
RUN bundle show coffee-rails

#-------------------------------------------------------------------------------
# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands. You can now run commands without
# specifying "bundle exec" on the console. If you need to, you can override the
# entrypoint as well.
#     docker run -it demo "rake test"
#     docker run -it --entrypoint="" demo "ls -la"
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
# or:
CMD ["/bin/true"]

# or:
# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
# CMD [ "config/containers/app_cmd.sh" ]
