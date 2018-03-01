FROM ruby:2.4.0

RUN apt-get update -qq && apt-get install -y build-essential

# install phantomjs for poltergeist
ENV PHANTOMJS_VERSION 2.1.1
ENV PHANTOMJS_FILE "phantomjs-$PHANTOMJS_VERSION-linux-x86_64"
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS_FILE.tar.bz2
RUN tar -xvjf $PHANTOMJS_FILE.tar.bz2
RUN mv $PHANTOMJS_FILE /usr/local/share
RUN ln -sf /usr/local/share/$PHANTOMJS_FILE/bin/phantomjs /usr/local/bin

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

# add user who will run app
ENV USERNAME wsops
RUN adduser $USERNAME --home /$USERNAME --shell /bin/bash --disabled-password --gecos ""
RUN chown -R $USERNAME:$USERNAME $APP_HOME

# # set bundle path to volume on separate container (configured in docker-compose)
# ENV BUNDLE_PATH /gembox
# ENV BUNDLE_APP_CONFIG /gembox/config

# copy over private key, and set permissions
RUN mkdir /$USERNAME/.ssh/
ADD id_rsa /$USERNAME/.ssh/id_rsa
RUN chown -R $USERNAME:$USERNAME /$USERNAME/.ssh/

# switch to applicaton user for ssh setup
USER $USERNAME

# create known_hosts
RUN touch /$USERNAME/.ssh/known_hosts
# add github key
RUN ssh-keyscan -t rsa github.com >> /$USERNAME/.ssh/known_hosts
