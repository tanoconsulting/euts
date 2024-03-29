ARG mysql_version=5.7
ARG db_vendor=mysql

FROM ${db_vendor}:${mysql_version}
LABEL mysql.version=${mysql_version}
LABEL com.tanoconsulting.euts.project_name=${project_name}

ARG mysql_version=5.7
ARG db_vendor=mysql
ARG do_shrink_container=true
ARG do_update_os=true
ARG project_name=euts
ARG timezone=none

# Configure timezone
# @todo make this work for apt, microdnf and yum
# -----------------------------------------------------------------------------
#RUN if [ "${timezone}" != "none" ]; then echo "${timezone}" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata; fi

# Base packages
# -----------------------------------------------------------------------------
# debian base OS
RUN if [ "${db_vendor}" = "mysql" -a "${mysql_version}" = "5.6" ]; then echo 'deb http://deb.freexian.com/extended-lts stretch main contrib non-free' > /etc/apt/sources.list; fi
RUN if apt-get -h >/dev/null 2>/dev/null; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated install \
    procps; \
    fi
# oracle base OS, mysql 5.7+
RUN if yum -h >/dev/null 2>/dev/null; then yum -y install \
    procps \
    which; \
    fi
# oracle base OS, mysql 8.0+
RUN if microdnf -h >/dev/null 2>/dev/null; then microdnf -y install \
    procps \
    which; \
    fi

# Was failing for MySQL 5.6 image before freexian fix; it possibly fails for 5.7 now... \
# Also: it should cater to microdnf and yum, too
# -----------------------------------------------------------------------------
#RUN if [ "${do_update_os}" != "false" ]; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --allow-unauthenticated; fi

# Clear archives in apt cache folder to slim down the image
# NB: this in fact only works as intended if executed in the same step as the apt update and install...
# @todo make this work for apt, microdnf and yum
# -----------------------------------------------------------------------------
#RUN if [ "${do_shrink_container}" != "false" ]; then apt-get clean && rm -rf /var/lib/apt/lists/*; fi

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 755 /root/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["mysqld"]
