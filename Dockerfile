FROM ruby:3.4-slim AS base

ENV APP_HOME=/app
WORKDIR $APP_HOME

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

ARG API_KEY
ENV API_KEY=${API_KEY}

ARG FOOTBALL_API_KEY
ENV FOOTBALL_API_KEY=${FOOTBALL_API_KEY}

ARG ANTHROPIC_API_KEY
ENV ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

ENV PORT=8080
EXPOSE 8080

CMD ["ruby", "server.rb"]
