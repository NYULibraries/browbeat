FROM quay.io/nyulibraries/selenium_chrome_headless_ruby:2.5.7-slim-chrome_79-chore_run_as_non_root 

# disable security level to avoid error when connecting to shibboleth; temporary please remove when fixed by shibboleth
USER root
RUN sed -i "s|CipherString = DEFAULT@SECLEVEL=2|#CipherString = DEFAULT@SECLEVEL=2|g" /etc/ssl/openssl.cnf

ENV INSTALL_PATH /app
WORKDIR $INSTALL_PATH

ARG BUILD_PACKAGES='git build-essential zlib1g-dev'
ARG RUN_PACKAGES='curl'
COPY --chown=docker:docker Gemfile Gemfile.lock ./
RUN apt-get update && apt-get -y --no-install-recommends install $BUILD_PACKAGES $RUN_PACKAGES \
  && gem install bundler -v '1.16.5' \
  && bundle config --local github.https true \
  && bundle install --jobs 20 --retry 5 \
  && rm -rf /root/.bundle && rm -rf /root/.gem \
  && rm -rf /usr/local/bundle/cache \
  && apt-get --purge -y autoremove $BUILD_PACKAGES \
  && apt-get clean && rm -rf /var/lib/apt/lists/* \
  && chown -R docker:docker /usr/local/bundle

RUN mkdir coverage && chown -R docker:docker coverage

USER docker
COPY --chown=docker:docker . ./

CMD FAILURE_TRACKER=off rake browbeat:check:production
