FROM nyulibraries/selenium_chrome_headless_ruby:2.5.1-slim

ENV INSTALL_PATH /app
WORKDIR $INSTALL_PATH

RUN groupadd -g 1000 docker -r && \
  useradd -u 1000 -r --no-log-init -m -d $INSTALL_PATH -g docker docker

ENV BUILD_PACKAGES git build-essential zlib1g-dev
ENV RUN_PACKAGES curl
COPY --chown=docker:docker Gemfile Gemfile.lock ./
RUN bundle config --global github.https true
RUN apt-get update && apt-get -y --no-install-recommends install $BUILD_PACKAGES $RUN_PACKAGES \
  && gem install bundler && bundle install --jobs 20 --retry 5 \
  && apt-get --purge -y autoremove $BUILD_PACKAGES \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && chown -R docker:docker ./ \
  && chown -R docker:docker /usr/local/bundle

COPY --chown=docker:docker . ./

USER docker

CMD FAILURE_TRACKER=off rake browbeat:check:production
