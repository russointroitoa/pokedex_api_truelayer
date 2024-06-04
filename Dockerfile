ARG RUBY_VERSION=3.2.0
FROM ruby:$RUBY_VERSION

WORKDIR usr/src/app

# Rails Master Key
ARG RAILS_MASTER_KEY

# Path to Bundler
ENV BUNDLE_APP_CONFIG="/usr/src/app/bundle"
# Cache all gems
ENV BUNDLE_CACHE_ALL=true
# Set GITHUB_TOKEN to avoid hardcoding the secret value
# ENV GITHUB_TOKEN=$GITHUB_TOKEN
# Set RAILS_MASTER_KEY to avoid hardcoding the secret value
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
