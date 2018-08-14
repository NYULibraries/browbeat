FROM nyulibraries/selenium_chrome_headless_ruby:2.5-slim

ENV INSTALL_PATH /app
WORKDIR $INSTALL_PATH

ENV BUILD_PACKAGES git build-essential zlib1g-dev
ENV RUN_PACKAGES curl
ADD Gemfile Gemfile.lock ./
RUN bundle config --global github.https true
RUN apt-get update && apt-get -y --no-install-recommends install $BUILD_PACKAGES $RUN_PACKAGES \
  && gem install bundler && bundle install --jobs 20 --retry 5 \
  && apt-get --purge -y autoremove $BUILD_PACKAGES \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD . ./

CMD FAILURE_TRACKER=off rake browbeat:check:production
