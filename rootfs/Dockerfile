FROM docker.io/library/fluentd:v1.14-1

USER root

COPY fluentd /fluentd
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh
ENV FLUENTD_CONF="/fluentd/etc/fluent.conf"

RUN apk add bash findutils \
    && apk add --update --virtual .build-deps sudo build-base ruby-dev \
    && gem install bundler:2.2.27 \
    && bundle config --global silence_root_warning 1 \
    && bundle install --gemfile=/fluentd/drycc-output/Gemfile \
    && rake --rakefile=/fluentd/drycc-output/Rakefile build \
    && fluent-gem install --no-document fluent-plugin-kubernetes_metadata_filter -v 2.9.2 \
    && fluent-gem install --no-document fluent-plugin-elasticsearch -v 5.1.4 \
    && fluent-gem install --no-document fluent-plugin-remote_syslog -v 1.0.0 \
    && fluent-gem install --no-document fluent-plugin-sumologic_output -v 1.7.3 \
    && fluent-gem install --no-document fluent-plugin-gelf-hs -v 1.0.8 \
    && fluent-gem install --no-document redis -v 4.5.1 \
    && fluent-gem install --local /fluentd/drycc-output/pkg/fluent-plugin-drycc_output-0.1.0.gem \
    && sudo gem sources --clear-all \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /root/.gem/ruby/*/cache/*.gem

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["/fluentd/sbin/boot"]
