The eZPlatform Ultimate Test Stack
==================================

Makes it easy to run _integration_ or _functional_ tests for eZPlatform/eZPublish bundles, supporting CI scenarios.

The target users are developers of open-source bundles for eZPlatform/eZPublish, who want to make sure their code works
with a specific version of the CMS, or a combination of versions.

It works by setting up a set of Docker Containers as test environment. In the main container, the desired version of eZP
is installed and the database is created with the stock schema definition. At this point, the testsuite of the bundle in
question can be executed.

Features:

* allows to run your bundle's tests on any version of eZPublish-Community, eZPlatform 1 and eZPlatform 2
* allows to run your bundle's tests on many versions of MySQL
* allows to run your bundle's tests on multiple versions of eZPlatform/eZPublish from a single source directory
* allows to specify extra composer packages to be installed and bundles to be activated
* provides a single command-line tool for managing the test stack and running tests, including maintenance operations
  such as database reset, logs cleanup, etc...

_Stay tuned for the first release..._

Requirements
------------

* Docker version ...
* Docker Compose version ...
* Bash shell
* Git (for a quick way to install this tool)

Installation
------------

To install in the `teststack` directory:

    git clone --depth 1 --branch 1.0.0 git@github.com:tanoconsulting/euts.git teststack

Note that you can use any other name for the folder where this tool will be installed - but so far it has only been
tested running from within the top-level project folder.

Quick Start
-----------

1. create a configuration file

   The default name for the config file is `.euts.env`. You can use a different file name, in which case you would
   have to tell it to the `teststack` command either via usage of the `-e` option, or by setting an environment
   variable.

       touch .euts.env

   In the config file, you need to set values at the very least for EZ_PACKAGES and EZ_BUNDLES - those are the Composer
   packages that are required to run your tests and the Symfony bundles that will be loaded in the eZP kernel

2. build the tests stack

       ./teststack/teststack build

   NB: this will take a long time. Also, it is recommended to have available a fast internet connection and lots of disk
   space.

3. run your tests

       ./teststack/teststack runtests

   NB: this currently assumes that your test suite uses PhpUnit, and the tests are located in /Tests/.

   If your test are driven by phpunit but located in a different folder, you can use:

        ./teststack/teststack runtests My/Test/Folder

   If your tests are driven by a shell script, you can use instead:

       ./teststack/teststack exec My/Test/SCript

4. stop the test stack

       ./teststack/teststack stop

Troubleshooting
---------------

Useful commands if the Test Stack fails building:

    ./teststack/teststack ps
    ./teststack/teststack logs

How to run the Symfony console:

     ./teststack/teststack console

How to connect to the database:

     ./teststack/teststack dbconsole

How to start a shell session in the container where tests are executed:

    ./teststack/teststack enter

Advanced Usage
--------------

### Running tests against multiple versions of eZPlatform

...

### Running tests on PostgreSQL

...

Tool Architecture & Design Decisions
------------------------------------

### Integration tests vs. unit tests

### What is the deal with the vendor folder?

...
