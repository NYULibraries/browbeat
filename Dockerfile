FROM nyulibraries/selenium_chrome_headless_ruby:2.5

# create directory
ENV APP_HOME /browbeat
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# add and install gems
ADD Gemfile* $APP_HOME/
RUN gem install bundler
RUN bundle install

# add application
ADD . $APP_HOME/

CMD FAILURE_TRACKER=off rake browbeat:check:production
