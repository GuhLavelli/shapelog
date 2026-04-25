FROM ruby:3.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      postgresql-client \
      curl \
      libyaml-dev \
      pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN gem install rails -v "~> 8.0"

WORKDIR /app

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
