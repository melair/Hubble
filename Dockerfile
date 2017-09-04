FROM ubuntu:latest

WORKDIR /hubble

ADD . /hubble

RUN apt-get update

RUN apt-get install -y curl tzdata

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;" && \
    /bin/bash -l -c "rvm install $(cat .ruby-version)" && \
    /bin/bash -l -c "rvm use --default $(cat .ruby-version) && gem install bundler" && \
    /bin/bash -l -c "rvm cleanup all"

RUN /bin/bash -l -c "bundle install"

CMD /bin/bash -l -c "DISCORD_TOKEN=\"$(cat /run/secrets/hubble_discord_token)\" TWITCH_TOKEN=\"$(cat /run/secrets/hubble_twitch_token)\" REDIS_HOST=\"redis\" REDIS_PORT=\"6379\" TZ=\"Europe/London\" bundle exec ruby hubble.rb"
