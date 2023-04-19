ARG os_vendor=debian
ARG debian_version=buster

FROM ${os_vendor}:${debian_version}
LABEL php_version.version=${php_version}
LABEL com.tanoconsulting.euts.project_name=${project_name}

ARG debian_mirror=none
ARG debian_version=buster
ARG do_shrink_container=true
ARG do_update_os=true
ARG php_version=default
ARG node_version=default
ARG project_name=euts
ARG timezone=none

# @todo the usage of several RUN/COPY steps in this docker file will most likely result in a huge image on disk.
# Otoh, the ordering of those steps has been devised to reduce the number of image layers to be rebuilt when the
# underlying configuration does change, making image rebuilds faster (this of course depends on the frequency of
# change in the image setup files). Would we be better off with using as few install steps as possible, ie. a few COPY
# at the start and then a single RUN?

# Set up debian mirror
# (use fixed debian mirrors if you have problems building on a given day)
# @todo if we are on jessie or stretch, we might as well just add the freexian elts repos. If we are on xenial, allow the
#       users who have a pro subscription (free) to use those repos (see https://ubuntu.com/pro/beta)
# -----------------------------------------------------------------------------
RUN if [ "${debian_mirror}" != "none" ]; then printf "deb ${debian_mirror} ${debian_version} main\n" > /etc/apt/sources.list; fi
RUN if [ "${debian_mirror}" != "none" -a ${debian_version} != "jessie" -a ${debian_version} != "stretch" ]; then printf "deb http://security.debian.org ${debian_version}/updates main\ndeb ${debian_mirror} ${debian_version}-updates main\n" >> /etc/apt/sources.list; fi

# Configure timezone
# -----------------------------------------------------------------------------
RUN if [ "${timezone}" != "none" ]; then echo "${timezone}" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata; fi

# Update the preinstalled packages
# -----------------------------------------------------------------------------
RUN if [ "${do_update_os}" != "false" ]; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --force-yes; fi

# Copy all the required shell scripts
COPY root/build/*.sh /root/build/
RUN chmod 755 /root/build/*.sh

# Install the required packages
# -----------------------------------------------------------------------------
# depending on os version, the package list will be different
RUN mkdir -p /usr/share/man/man1; mkdir -p /usr/share/man/man7; \
    cd /root/build/ && ./getpackages.sh "${php_version}" "${node_version}"

# Install Composer (a more recent version than the stock one)
# -----------------------------------------------------------------------------
RUN apt-get remove -y composer || echo An error on the line above is ok; \
    /root/build/getcomposer.sh && \
    chmod 755 /usr/local/bin/composer

# Create the local user account
# -----------------------------------------------------------------------------
RUN /root/build/createuser.sh

# Clear archives in apt cache folder to slim down the image
# NB: this in fact only works as intended if executed in the same step as the apt update and install...
# -----------------------------------------------------------------------------
RUN if [ "${do_shrink_container}" != "false" ]; then apt-get clean && rm -rf /var/lib/apt/lists/*; fi

# @todo should we move these two commands to the top of the dockerfile to increase layer shareability ?
COPY root/boot/*.sh /root/boot/
RUN chmod 755 /root/boot/*.sh

RUN echo '0' > /var/build_ok

WORKDIR /home/test/workspace

# 80: haproxy / varnish / apache
# 443: haproxy / apache
# 6379: redis
# 8983: solr
# 9300: elasticsearch
# 11211: memcached
EXPOSE 80 443 6379 8983 9300 11211

ENTRYPOINT ["/root/boot/entrypoint.sh"]
