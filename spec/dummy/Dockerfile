FROM ruby:2.5.3-alpine
CMD ["rails server -b 0.0.0.0 -p 9873"]
COPY spec/dummy /app
WORKDIR /app
RUN  bundle install
