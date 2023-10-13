FROM ruby:3.2.2

WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY . .

ENTRYPOINT ["bash", "-c", "chmod +x /app/entry_point.sh && /app/entry_point.sh"]
