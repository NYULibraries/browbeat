FROM quay.io/nyulibraries/selenium_chrome_headless_ruby:2.5.3-slim-chrome_72

ENV INSTALL_PATH /app
WORKDIR $INSTALL_PATH

RUN groupadd -g 2000 docker -r \
  && useradd -u 1000 -r --no-log-init -m -d $INSTALL_PATH -g docker docker \
  && chown -R docker:docker .

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
  && rm /usr/local/bundle/bin/chromedriver \
  && chown -R docker:docker /usr/local/bundle

RUN mkdir coverage && chown -R docker:docker coverage

COPY --chown=docker:docker . ./

# run microscanner
USER root
ARG AQUA_MICROSCANNER_TOKEN
RUN wget -O /microscanner https://get.aquasec.com/microscanner && \
  chmod +x /microscanner && \
  /microscanner ${AQUA_MICROSCANNER_TOKEN} || true && \
  rm -rf /microscanner
  
USER docker

CMD FAILURE_TRACKER=off rake browbeat:check:production
