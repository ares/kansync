FROM centos/ruby-24-centos7
WORKDIR /opt/app-root
COPY . .
RUN scl enable rh-ruby24 'bundle install'
ENV PATH "$PATH:/opt/app-root"
VOLUME /opt/app-root/profiles
