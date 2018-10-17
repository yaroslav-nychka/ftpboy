FROM ruby:2.5.1

RUN mkdir /app
WORKDIR /app
ADD . /app
RUN bundle install --retry 10 --jobs 4
