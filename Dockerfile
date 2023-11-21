FROM ruby:2.6.6-alpine
RUN apk add postgresql-dev git build-base nodejs bash openjdk11-jre
RUN mkdir -p /opt/mimemagic
WORKDIR /opt/reprosci
ENV FREEDESKTOP_MIME_TYPES_PATH=/opt/mimemagic
COPY src/Gemfile .
RUN bundle install
COPY src/. .
CMD ["bash", "start.sh"]
