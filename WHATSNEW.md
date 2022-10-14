Version 0.4.3
=============

* allow to pass in github authentication for composer via env var GITHUB_TOKEN

* moved `master` branch to `main`

Version 0.4.2
=============

* fix generation of code coverage with recent xdebug versions

Version 0.4.1
=============

* fix installing composer w. php 7.0, 7.1 on GitHub

Version 0.4
===========

* new: support usage via GitHub Actions besides Travis

* new: allow using Ubuntu instead of Debian as base OS for the docker containers

* new: allow using MariaDB instead of Mysql as DB for the docker containers

* fix: usage of `teststack -w $value`. Also, improve timeout measurement

* fix: make sure composer gets downgraded to version 2.2 when using php versions 5.6-7.1

* fix: make sure `teststack build` and `teststack setup` exit with non-0 code on failure to set up eZ

* change: `teststack exec` will not allocate a tty nor run in interactive mode by default. New cli options `-i` and `-t`
  are available for that command, which behave exactly the same way they do with `docker exec`.
  Also: `teststack runtests` and `teststack resetdb` do not allocate a terminal anymore

* change: revert to use of non-slim debian images as docker base images, to allow support of Ubuntu as container OS

* improve: fail when using `-s` or `-n` options for `teststack setup`

* improve: reinstall php on container restart if TESTSTACK_PHP_VERSION hash changed

* improve: when using docker, make sure mysql is available before declaring bootstrap finished

* add to the docs an example configuration using eZPlatform 2.4

* make it easier to reuse outside of Docker the script used to set up php

Version 0.3.1
=============

* fix: setup.sh failed on eZPlatform installs without the Legacy Bridge (bug introduced in 0.2)

Version 0.3
===========

* fix: make it possible to run multiple copies of the stack in parallel.
  In order to achieve this, env var TESTSTACK_PROJECT_NAME has been replaced with COMPOSE_PROJECT_NAME in config file .euts.env.
  In order to retain Backwards Compatibility, the old variable name is still accepted if the new one is not used.

* fix: setup.sh failed on Travis (bug introduced in 0.2)

Version 0.2
===========

* add support for installing (and automatically setting up) the Legacy Bridge as test dependency

* also, set up legacy siteaccesses configuration when running eZPublish-Community

* fix handling of the custom configuration file specified via env var EZ_TEST_CONFIG_SYMFONY

* fix cleaning up eZ caches and logs via commands `teststack cleanup` or `cleanup.sh`

* move to using 'slim' versions of Debian Docker images to save disk space and network bandwidth

* environment variables `http_proxy`, `https_proxy` and `COMPOSER_AUTH` are now exported to the test container

* made command `teststack setup` more robust (when dealing with wrong/incomplete symlinks)

* small improvements in error handling

* more verbose messages are emitted during build, bootstrap, app setup

* add more labels to the containers; use better names for the container images built

Version 0.1
===========

Initial release
