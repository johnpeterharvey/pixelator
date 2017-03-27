FROM ubuntu:devel

VOLUME /input
VOLUME /output

# Build tools and ruby
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y curl build-essential pkg-config ruby-dev libpng-dev libjpeg-dev

# Install ImageMagick 7 - not available from repository yet
RUN curl http://www.imagemagick.org/download/ImageMagick.tar.gz | tar xvz \
 && cd ImageMagick* \
 && ./configure --prefix=/usr \
 && make install \
 && ldconfig /usr/local/lib

# Install required gems
ADD Gemfile /
RUN gem install bundler \
 && bundle install

# Actual code
ADD main.rb /

WORKDIR /
ENTRYPOINT ["/usr/bin/ruby", "main.rb"]
