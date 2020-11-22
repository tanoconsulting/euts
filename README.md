The eZPlatform Ultimate Test Stack
==================================

Makes it easy to run integration tests for eZPlatform/eZPublish bundles, supporting CI scenarios.

The target users are developers of open-source bundles for eZPlatform/eZPublish, who want to make sure their code works
with a specific version of the CMS, or a combination of versions.

It works by setting up a set of Docker Containers as test environment. In the main container, the desired version of eZP
is installed and the database is created with the stock schema definition. At this point, the testsuite of the bundle in
question can be executed.

Features:

* allows to run your bundle's tests on any version of eZPublish-Community, eZPlatform 1 and eZPlatform 2
* allows to run your bundle's tests on any version of MySQL
* allows to run your bundle's tests on multiple versions of eZPublish/eZPlatform from a single source directory
* allows to specify extra composer packages to be installed and bundles to be activated
* provides a single command-line tool for managing the test stack and running tests, including maintenance operations
  such as database reset, logs cleanup, etc...

_Stay tuned for the first release..._

Requirements
------------

* Docker version ...
* Docker Compose version ...

Installation
------------

...

Usage
-----

...
