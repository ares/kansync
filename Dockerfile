FROM centos/ruby-27-centos7
WORKDIR /opt/app-root
COPY --chown=default:root . .
ENV SHELL=/bin/bash
CMD rm Gemfile.lock
RUN bundle install
ENV PATH "$PATH:/opt/app-root"
VOLUME /opt/app-root/profiles
