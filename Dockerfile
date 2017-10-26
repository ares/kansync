FROM centos/ruby-24-centos7
WORKDIR /opt/app-root
COPY . .
RUN scl enable rh-ruby24 'bundle install'
VOLUME /opt/app-root/profiles

CMD scl enable rh-ruby24 './kansync_loop'
