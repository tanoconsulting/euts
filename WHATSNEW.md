Version 0.6.1
=============

* fix: install Composer dependencies from a given composer.lock file (it broke recently because apparently Composer
  now requires a composer.json file to be available in any case in that scenario)

Version 0.6.0
=============

* improved support for testing projects depending on eZPlatform 3.1, 3.2 and 3.3 (the latter is considered experimental)

* use a per-project directory to store the db data, easing execution from a single dir of tests running on different db versions

* install nodejs and npm by default in the test container (not supported yet for debian jessie and stretch containers)

* the `teststack` command learned action `cleanup containers`; `cleanup docker-images` was renamed to `cleanup dead-images`

* fix: do not try to install php from a custom repository when the desired version is available in the apt repos already
  set up in the operating system

Version 0.5.2
=============

* relaxed the need to specify the version of eZ in use in env var EZ_PACKAGES when using EZ_COMPOSER_LOCK, for the case
  of tests running on GHA/Travis

* improve compatibility with mariadb docker images

Version 0.5.1
=============

* fixed creating the test database user account so that it can be accessed from all php versions when using MySQL 8.0
  (useful for GitHub Actions workers as Ubuntu 18 is deprecated now, and Ubuntu 20 defaults to MySQL 8.0.30)

* fixed building the MySQL container for recent versions of MySQL 5.7/8.0 (DockerHub now uses Oracle base images)

* added a configuration example for running tests using GitHub Actions

* added: support env vars GITHUB_TOKEN and PACKAGIST_TOKEN as an alternative to COMPOSER_AUTH

* BC break: when using EZ_COMPOSER_LOCK to specify the set of packages to install, it is now mandatory to specify
  as well the eZP package in use as value for the EZ_PACKAGES env var. This requirement might be relaxed in
  future releases

Version 0.5.0
=============

* allow to pass in authentication for composer via env vars GITHUB_TOKEN, PACKAGIST_TOKEN

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
