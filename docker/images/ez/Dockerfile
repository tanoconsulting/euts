ARG debian_version=buster

FROM debian:${debian_version}

ARG debian_mirror=none
ARG debian_version=buster
ARG php_version=default
ARG do_update_os=true
ARG timezone=none

# Set up debian mirror
# (use fixed debian mirrors if you have problems building on a given day)
# -----------------------------------------------------------------------------
RUN if [ "${debian_mirror}" != "none" ]; then printf "deb ${debian_mirror} ${debian_version} main\ndeb http://security.debian.org ${debian_version}/updates main\ndeb ${debian_mirror} ${debian_version}-updates main" > /etc/apt/sources.list; fi

# Configure timezone
# -----------------------------------------------------------------------------
RUN if [ "${timezone}" != "none" ]; then echo "${timezone}" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata; fi

# Update the preinstalled packages
# -----------------------------------------------------------------------------
RUN if [ "${do_update_os}" != "false" ]; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; fi

# Install the required packages
# -----------------------------------------------------------------------------
# depending on Debian version, the package list will be different
COPY getpackages.sh getphp_sury.sh getphp_default.sh /root/
RUN mkdir -p /usr/share/man/man1; \
    chmod 755 /root/getpackages.sh; chmod 755 /root/getphp_default.sh; chmod 755 /root/getphp_sury.sh; \
    cd /root && ./getpackages.sh "${php_version}"

# Install Composer (a more recent version than the stock one from Debian)
# -----------------------------------------------------------------------------
COPY getcomposer.sh /root/
RUN apt-get remove -y composer || echo An error on the line above is ok; \
    chmod 755 /root/getcomposer.sh; \
    cd /root && ./getcomposer.sh && \
    mv /usr/local/bin/composer.phar /usr/local/bin/composer && \
    chmod 755 /usr/local/bin/composer

# Create the local user account
# -----------------------------------------------------------------------------
COPY createuser.sh /root/
RUN chmod 755 /root/createuser.sh; \
    cd /root && ./createuser.sh

# -----------------------------------------------------------------------------

# Shrink image: clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# @todo should we move these two commands to the top of the dockerfile to increase shareability ?
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 755 /root/entrypoint.sh

WORKDIR /home/test/bundle

# 80: haproxy / varnish / apache
# 443: haproxy / apache
# 6379: redis
# 8983: solr
# 9300: elasticsearch
# 11211: memcached
EXPOSE 80 443 6379 8983 9300 11211

ENTRYPOINT ["/root/entrypoint.sh"]
