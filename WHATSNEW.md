Version 0.2
===========

* add support for installing (and automatically setting up) the Legacy Bridge as test dependency

* also, set up legacy siteaccesses configuration when running eZPublish-Community

* move to using 'slim' versions of Debian Docker images to save space

* environment variables `http_proxy`, `https_proxy` and `COMPOSER_AUTH` are now exported to the test container

* fix cleaning up eZ caches and logs

* small improvements in error handling

* more verbose messages during build, bootstrap, app setup

Version 0.1
===========

Initial release
