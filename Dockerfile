FROM alpine:latest
MAINTAINER Nklya <nklya@hotmail.com>

LABEL   Name="mydocker-redmine"\
        Version="latest"

ENV BRANCH_NAME=master \
    RAILS_ENV=production

WORKDIR /opt/redmine

RUN addgroup -S redmine \
    && adduser -S -G redmine redmine \
	&& apk --no-cache add --virtual .run-deps \
                mariadb-client-libs \
	        	sqlite-libs \
                imagemagick \
                tzdata \
                ruby \
		        ruby-bigdecimal \
		        ruby-bundler \
                tini \
                su-exec \
                bash \
    && apk --no-cache add --virtual .build-deps \
                build-base \
                ruby-dev \
                libxslt-dev \
                imagemagick-dev \
                mariadb-dev \
                sqlite-dev \
                linux-headers \
                patch \
                coreutils \
                curl \
                git \
        && echo 'gem: --no-document' > /etc/gemrc \
        && gem update --system \
	&& git clone -b ${BRANCH_NAME} https://github.com/redmine/redmine.git . \
        && rm -rf files/delete.me log/delete.me .git test\
        && mkdir -p tmp/pdf public/plugin_assets \
        && chown -R redmine:redmine ./\
	&& for adapter in mysql2 sqlite3; do \
		echo "$RAILS_ENV:" > ./config/database.yml; \
		echo "  adapter: $adapter" >> ./config/database.yml; \
		bundle install --without development test; \
	done \
	&& rm ./config/database.yml \
	&& rm -rf /root/* `gem env gemdir`/cache \
        && apk --purge del .build-deps

VOLUME /opt/redmine/files

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9000
#USER redmine

CMD ["rails", "server", "-b", "0.0.0.0"]
