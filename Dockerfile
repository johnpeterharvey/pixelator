FROM ubuntu:devel

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y graphicsmagick build-essential pkg-config ruby-dev

VOLUME /output
ADD . /

RUN gem install bundler \
 && bundle install

ENTRYPOINT ["/bin/bash"]
