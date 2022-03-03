FROM docker.io/drycc/base:bullseye

USER root

COPY fluentd /fluentd
WORKDIR /fluentd
ENV FLUENTD_CONF="/fluentd/etc/fluent.conf" \
  RUBY_VERSION="3.1.0" \
  FLUENTD_VERSION="1.14.5"

RUN buildDeps='libyaml-dev build-essential'; \
  install-packages $buildDeps \
  && install-stack ruby $RUBY_VERSION \
  && install-stack fluentd $FLUENTD_VERSION && . init-stack \
  && gem install bundler:2.2.27 \
  && bundle config --global silence_root_warning 1 \
  && bundle install --gemfile=/fluentd/drycc-output/Gemfile \
  && rake --rakefile=/fluentd/drycc-output/Rakefile build \
  && fluent-gem install --no-document fluent-plugin-kubernetes_metadata_filter -v 2.9.4 \
  && fluent-gem install --no-document fluent-plugin-elasticsearch -v 5.1.4 \
  && fluent-gem install --no-document fluent-plugin-remote_syslog -v 1.0.0 \
  && fluent-gem install --no-document fluent-plugin-sumologic_output -v 1.7.3 \
  && fluent-gem install --no-document fluent-plugin-gelf-hs -v 1.0.8 \
  && fluent-gem install --no-document influxdb -v 0.8.1 \
  && fluent-gem install --no-document redis -v 4.5.1 \
  && fluent-gem install --local /fluentd/drycc-output/pkg/fluent-plugin-drycc_output-0.1.0.gem \
  && gem sources --clear-all \
  # cleanup
  && apt-get purge -y --auto-remove $buildDeps \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf \
        /usr/share/doc \
        /usr/share/man \
        /usr/share/info \
        /usr/share/locale \
        /var/lib/apt/lists/* \
        /var/log/* \
        /var/cache/debconf/* \
        /etc/systemd \
        /lib/lsb \
        /lib/udev \
        /usr/lib/`echo $(uname -m)`-linux-gnu/gconv/IBM* \
        /usr/lib/`echo $(uname -m)`-linux-gnu/gconv/EBC* \
        /var/cache/apk/* /root/.gem/ruby/*/cache/*.gem \
  && bash -c "mkdir -p /usr/share/man/man{1..8}"

CMD ["/fluentd/sbin/boot"]
