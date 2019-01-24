FROM ruby:2.5.3-alpine
CMD ["bundle exec rails server -b 0.0.0.0 -p 9873"]
# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                postgresql-dev \
                                nodejs \
                                tzdata

ENV APP_PATH /app

# Different layer for gems installation
COPY ./spec/dummy $APP_PATH
WORKDIR $APP_PATH
RUN bundle install

EXPOSE 9873
