FROM ubuntu:devel

VOLUME /input
VOLUME /output

# Build tools and ruby
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y curl build-essential pkg-config ruby-dev libpng-dev libjpeg-dev fontconfig locate libfreetype6-dev libfontconfig1-dev ghostscript

# Install ImageMagick 7 - not available from repository yet
RUN curl http://www.imagemagick.org/download/ImageMagick.tar.gz | tar xvz \
 && cd ImageMagick* \
 && ./configure --prefix=/usr \
 && make install \
 && ldconfig /usr/local/lib

# Find and add fonts - the script uses locate
RUN updatedb \
 && curl http://www.imagemagick.org/Usage/scripts/imagick_type_gen -o imagick_type_gen \
 && perl imagick_type_gen > /usr/etc/ImageMagick-7/type.xml

# Install required gems
ADD Gemfile /
RUN gem install bundler \
 && bundle install

# Actual code
ADD main.rb /

WORKDIR /
ENTRYPOINT ["/usr/bin/ruby", "main.rb"]
