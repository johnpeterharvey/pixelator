FROM ubuntu:devel

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y graphicsmagick build-essential pkg-config ruby-dev

VOLUME /input
VOLUME /output
ADD Gemfile Gemfile.lock /

RUN gem install bundler \
 && bundle install

ADD main.rb /

ENTRYPOINT ["/usr/bin/ruby", "main.rb"]
