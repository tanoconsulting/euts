Version 0.4 (wip)
=================

* support easy usage via GitHub Actions besides travis

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
