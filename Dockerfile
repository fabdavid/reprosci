FROM ruby:2.7.0-alpine
RUN apk add postgresql-dev git build-base nodejs bash openjdk8-jre grep\
    python3 \
    py3-pip \
    libxml2-dev \
    libxslt-dev \
    zlib-dev \
    jpeg-dev \
    libffi-dev \
    curl \
    gfortran \
    openblas-dev \
    lapack-dev \
    python3-dev \
    poppler-utils

#RUN pip3 install --upgrade pip
#RUN pip3 install pygetpapers pandas

RUN gem update --system 3.3.22
RUN mkdir -p /opt/mimemagic
WORKDIR /opt/reprosci
ENV FREEDESKTOP_MIME_TYPES_PATH=/opt/mimemagic
COPY src/Gemfile .
#RUN gem update --system
RUN bundle install --verbose
COPY src/. .
CMD ["bash", "start.sh"]
