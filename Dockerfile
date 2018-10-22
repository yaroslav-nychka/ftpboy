FROM ruby:2.5.1

RUN mkdir /app
WORKDIR /app
ADD . /app
RUN bundle install
CMD bundle exec sidekiq -r ./lib/worker.rb
