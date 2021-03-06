FROM python:3.6-slim
MAINTAINER Ruslan Gainutdinov <ruslanfg+nospam@gmail.com>

# Superset setup options
ENV SUPERSET_VERSION 0.28.1
ENV SUPERSET_HOME /superset
ENV SUP_ROW_LIMIT 5000
ENV SUP_WEBSERVER_THREADS 8
ENV SUP_WEBSERVER_PORT 8088
ENV SUP_WEBSERVER_TIMEOUT 60
ENV SUP_SECRET_KEY 'thisismysecretkey'
ENV SUP_META_DB_URI "sqlite:///${SUPERSET_HOME}/superset.db"
ENV SUP_CSRF_ENABLED True
ENV SUP_CSRF_EXEMPT_LIST []
ENV MAPBOX_API_KEY ''

ENV PYTHONPATH $SUPERSET_HOME:$PYTHONPATH

# admin auth details
ENV ADMIN_USERNAME admin
ENV ADMIN_FIRST_NAME admin
ENV ADMIN_LAST_NAME user
ENV ADMIN_EMAIL admin@nowhere.com
ENV ADMIN_PWD superset

ENV REDIS_URL none

# Supports PostgreSQL, MySQL, Microsoft and Sybase ASE connections
ENV DB_PACKAGES libpq5 libpq-dev default-libmysqlclient-dev unixodbc unixodbc-dev freetds-dev
ENV DB_PIP_PACKAGES psycopg2 mysql-connector pyodbc numpy sqlalchemy-redshift redis redis-cache

RUN apt-get update \
&& apt-get install -y \
  build-essential gcc \
  libssl-dev libffi-dev libsasl2-dev libldap2-dev $DB_PACKAGES \
&& pip install --no-cache-dir \
  $DB_PIP_PACKAGES flask-appbuilder superset==$SUPERSET_VERSION \
  # As of v0.27.0 we must specify an older version of flask for compatibility
  'flask==0.12.4' \
&& apt-get remove -y \
  build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev \
&& apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# remove build dependencies
RUN mkdir $SUPERSET_HOME

COPY superset-init.sh /superset-init.sh
COPY odbcinst.ini /etc/odbcinst.ini
COPY odbc.ini /etc/odbc.ini
COPY freetds.conf /etc/freetds/freetds.conf
RUN chmod +x /superset-init.sh

VOLUME $SUPERSET_HOME
EXPOSE 8088

# since this can be used as a base image adding the file /docker-entrypoint.sh
# is all you need to do and it will be run *before* Superset is set up
ENTRYPOINT [ "/superset-init.sh" ]
