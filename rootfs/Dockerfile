ARG CODENAME
FROM registry.drycc.cc/drycc/base:${CODENAME}

USER root

COPY fluentd /fluentd
WORKDIR /fluentd
ENV FLUENTD_CONF="/fluentd/etc/fluent.conf" \
  RUBY_VERSION="3.2" \
  FLUENTD_VERSION="1.16.1"

RUN buildDeps='libyaml-dev build-essential'; \
    runDeps="net-tools" \
  && install-packages $buildDeps \
  && install-packages $runDeps \
  && install-stack ruby $RUBY_VERSION \
  && install-stack fluentd $FLUENTD_VERSION && . init-stack \
  && bundle update --all --gemfile=/fluentd/drycc-output/Gemfile \
  && bundle install --gemfile=/fluentd/drycc-output/Gemfile \
  && rake --rakefile=/fluentd/drycc-output/Rakefile build \
  && fluent-gem install --no-document fluent-plugin-kubernetes_metadata_filter -v 3.2.0 \
  && fluent-gem install --no-document fluent-plugin-elasticsearch -v 5.3.0 \
  && fluent-gem install --no-document fluent-plugin-remote_syslog -v 1.1.0 \
  && fluent-gem install --no-document fluent-plugin-sumologic_output -v 1.8.0 \
  && fluent-gem install --no-document fluent-plugin-gelf-hs -v 1.0.8 \
  && fluent-gem install --no-document influxdb-client -v 2.9.0 \
  && fluent-gem install --no-document redis -v 5.0.6 \
  && fluent-gem install --local /fluentd/drycc-output/pkg/fluent-plugin-drycc_output-0.1.0.gem \
  && gem sources --clear-all \
  # cleanup
  && scanelp /opt/drycc/fluentd > runtime.txt \
  && apt-get purge -y --auto-remove $buildDeps \
  && install-packages $(< runtime.txt) \
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
