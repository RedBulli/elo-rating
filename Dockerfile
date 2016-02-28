FROM ruby:2.3.0

EXPOSE 5000
ENV PORT 5000

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /app
WORKDIR /app

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install --jobs 3 --retry 5

COPY . ./

CMD bundle exec foreman start
