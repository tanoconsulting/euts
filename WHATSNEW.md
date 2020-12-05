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
