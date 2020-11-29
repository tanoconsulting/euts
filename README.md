The eZPlatform Ultimate Test Stack
==================================

Makes it easy to run _integration_ or _functional_ tests for eZPlatform/eZPublish bundles, both locally (via Docker) and
on popular CI services such as Travis or GitHub Actions.

The target users are developers of open-source bundles for eZPlatform/eZPublish, who want to make sure their code works
with a specific version of the CMS, or on a combination of versions.

Features:

* allows to run your bundle's tests on any version of eZPublish-Community, eZPlatform 1 and eZPlatform 2
* allows to run your bundle's tests on multiple versions of eZPlatform/eZPublish from a single source directory
* allows to specify extra composer packages to be installed and bundles to be activated
* allows to run your bundle's tests on many versions of PHP (local execution only)
* allows to run your bundle's tests on many versions of MySQL (local execution only)
* provides a single command-line tool for managing the test stack and running tests, including maintenance operations
  such as database reset, logs cleanup, etc... (local execution only)

It works by setting up a set of Docker Containers as test environment. In the main container, the desired version of eZP
is installed and configured and the database is created with the stock schema definition.
At this point, the testsuite of the bundle in question can be executed.

Requirements
------------

* Docker version 1.13 or later
* Docker Compose version ...
* Bash shell
* Git (for a quick way to download this tool)

Installation
------------

To install in the `teststack` directory:

    git clone --depth 1 --branch 1.0.0 https://github.com/tanoconsulting/euts.git teststack

Note that you can use any other name for the folder where this tool will be installed - but so far it has only been
tested running from within the top-level project folder.

Quick Start
-----------

0. write some tests for your bundle, which can be executed from the command-line

1. create a configuration file

   The default name for the config file is `.euts.env`. You can use a different file name, in which case you would
   have to tell it to the `teststack` command either via usage of the `-e` option, or by setting an environment
   variable.

       touch .euts.env

   In the config file, you need to set values at the very least for EZ_PACKAGES and EZ_BUNDLES - those are the Composer
   packages that are required to run your tests and the Symfony bundles that will be loaded in the eZP kernel.
   Some example configuration files can be found in the _doc/config_exaples_ folder.
   The full list of available config variables and their purpose is found in [.euts.env.example](./.euts.env.example).

2. make sure that your project's `composer.json` is compatible with the Test Stack:

   * if you are using phpunit for your tests, your composer.json file should have it in the `require-dev` section
   * the `require-dev` section should not contain the packages defined in the EZ_PACKAGES config variable (this
     commonly includes the eZPlatform bundle)

3. build the tests stack

       ./teststack/teststack build

   NB: this will take a long time. Also, it is recommended to have available a fast internet connection and lots of disk
   space.

4. run your tests

       ./teststack/teststack runtests My/Test/Folder

   NB: this currently assumes that your test suite uses PhpUnit.

   If your tests are driven by a shell script, you can use instead:

       ./teststack/teststack exec My/Test/Script

5. stop the test stack

       ./teststack/teststack stop

6. commit the `.euts.env` file into version control. Don't forget to add the `/teststack` folder to your .gitignore file
   to avoid accidentally committing it to your project's source code

7. Set up your tests to be run on Travis

   See an example configuration [.travis.yml](doc/config_examples/.travis.yml) file

   Note that, to perform tests on Travis, it is not necessary to run the whole tests stack - for most scenarios eZ
   can be set up and the test suite execute without building and starting Docker containers.

8. Set up your tests to be run on GitHub Actions

    To be documented...

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

How It Works
------------

### Integration tests vs. unit tests

...

### What is the deal with composer.json

...

### What is the deal with the vendor folder?

...

### Build vs. Setup phases

...

### Directory layout within the eZ Container

...

Advanced Usage
--------------

### Running tests against multiple versions of eZPlatform

...

### Running tests on PostgreSQL

...

### Using custom php configuration for your tests

...

### Using custom Symfony configuration for your tests

...

FAQ
---

Q: what is installed out of the box in the test Container?

A: besides php, you get apache, git, memcached, redis, varnish.
   Installed php extensions are: curl gd intl json memcached mysql pgsql xdebug xsl.

Q: Why not use the Docker containers definition from eZPlatform?

A: Because we have to be able to test against eZPublish-Community, as well as eZPlatform 1 and eZPlatform 2, which do not
   come with Docker Containers in their source code

Q: why can't I install the Test Stack via Composer?

A: because of the way we handle installation of Composer dependencies, this tool would have to be installed _before_ all
   other dependencies as well as in a _separate_ vendor folder. It thus makes little sense to use Composer for it

Q: how are you testing this Test Stack itself?

A: Inception!!!
