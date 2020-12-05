The eZPlatform Ultimate Test Stack
==================================

Makes it easy to run _integration_ or _functional_ tests for eZPlatform/eZPublish bundles, both locally (via Docker) and
on popular CI services such as Travis or GitHub Actions.

The target users are developers of bundles for eZPlatform/eZPublish, who want to make sure their code works with
a specific version of the CMS, or on a combination of versions.

Features:

* allows to run your bundle's tests on any version of eZPublish-Community, eZPlatform 1 and eZPlatform 2
* allows to run your bundle's tests on multiple versions of eZPlatform/eZPublish from a single source directory
* allows to specify extra composer packages to be installed and symfony bundles or legacy extensions to be activated
* allows to run your bundle's tests on many versions of PHP (Docker execution only)
* allows to run your bundle's tests on many versions of MySQL (Docker execution only)
* provides a single command-line tool for managing the test stack and running tests, including maintenance operations
  such as database reset, logs cleanup, etc... (Docker execution only)

It works by:
1. setting up a set of Docker Containers as test environment, with all the components required to run eZ (php, mysql, etc...)
2. downloading and setting up the desired version of eZP and creating the database with the stock schema definition.
At this point, the testsuite of the bundle in question can be executed.

Step 1 can be omitted when the tests are run on a server which already has php/mysql installed, such as a CI environment.

Requirements
------------

* Git (for a quick way to download this tool)
* Bash shell

For running tests in Docker containers:
* Docker version 1.13 or later
* Docker Compose version ...

For running tests without Docker: see the requirements for the version of eZPlatform that you intend to use

Installation
------------

To install in the `teststack` directory:

    git clone --depth 1 --branch 0.2.0 https://github.com/tanoconsulting/euts.git teststack

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
   * if you are running tests with either eZPublish 5 or the Legacy-Bridge, you should have this configuration:

         "extra": {
             "ezpublish-legacy-dir": "vendor/ezsystems/ezpublish-legacy"
         },

3. build the tests stack

       ./teststack/teststack build

   NB: this will take a long time. Also, it is recommended to have available a fast internet connection and lots of disk
   space.

4. run your tests

       ./teststack/teststack runtests My/Test/Folder

   To make sure that the eZ database is reset and the eZ caches are cleaned on each test run, use:

       ./teststack/teststack -r runtests My/Test/Folder

   NB: this currently assumes that your test suite uses PhpUnit.
   If your tests are driven by any other command, you can use instead:

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

* Useful commands if the Test Stack fails building:

      ./teststack/teststack ps
      ./teststack/teststack logs

* How to run the Symfony console:

       ./teststack/teststack console

* How to connect to the database:

       ./teststack/teststack dbconsole

  (note that the mysql client will be running within the test container, so the path it will 'see' for reading/writing
  files are not the same as the ones in the host computer).

* How to start a shell session in the container where tests are executed:

      ./teststack/teststack enter

  once you are in the container, an easy way to run the Symfony console, regardless of the eZ version installed, is:

      ../teststack/bin/sfconsole.sh

* If you get an error 'Your requirements could not be resolved to an installable set of packages.' due to the package
  `roave/security-advisories dev-master`, you can work around it by the following changes in your composer.json file:

  1. add to the `repositories` section the following code:

          {
              "type": "vcs",
              "url": "https://github.com/kaliop-uk/SecurityAdvisoriesNoConflicts",
              "no-api": true
          }

  2.  add to the `require-dev` section the following:

          "roave/security-advisories": "dev-disablechecks as dev-master"

* If you get an error 'Could not authenticate against github.com', you can set in the .euts.env file something like:

      COMPOSER_AUTH='{"github-oauth": {"github.com": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"}}'

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

### Directory layout on the host

    - Bundle folder (root)
        - .euts.env
        - teststack
            - ...
        - vendor_xxx
            - ezsystems
                - ezplatform (for eZPlatform)
                - ezpublish-community (for eZPublish-Community)
                - ezpublish-legacy (for eZPublish-Community or eZPlatform with LegacyBrdige)
                - ...
            - ... (other dependencies)
        - ... (your bundle code)

### Directory layout within the eZ Container

    - /home/tests
        - teststack (mount of the 'teststack' host folder)
            - ...
        - bundle (mount of the 'bundle root' host folder)
            - vendor (symlink to vendor_xxx)
            - vendor_xxx
            - ...

Advanced Usage
--------------

### Defining a Test Matrix: running tests against multiple versions of eZPlatform

...

### Running tests on PostgreSQL

...

### Using custom php configuration for your tests

...

### Using custom Symfony configuration for your tests

...

FAQ
---

Q: Which Symfony environment is used to run the tests?

A: by default we run all tests and symfony commands using the `behat` symfony environment.
   You can change this by setting a value for APP_ENV or SYMFONY_ENV in your .euts config file, but be warned that, at
   least for the moment, the automatic setting up of the configuration files to make eZP work within the test stack
   environment will still be done for the `behat` symfony environment.

Q: Which eZ Siteaccesses are available to run the tests?

A: behat_site, behat_site_admin as well as behat_site_legacy_admin for eZPublish5 and Legacy-Bridge

Q: What is installed out of the box in the test Container?

A: besides php, you get apache, git, memcached, redis, varnish.
   Installed php extensions are: curl gd intl json memcached mysql pgsql xdebug xsl.

Q: Why not use the Docker containers definition from eZPlatform?

A: Because we have to be able to test against eZPublish-Community, as well as eZPlatform 1 and eZPlatform 2, which do not
   come with Docker Containers in their source code

Q: Why can't I install the Test Stack via Composer?

A: because of the way we handle installation of Composer dependencies, this tool would have to be installed _before_ all
   other dependencies as well as in a _separate_ vendor folder. It thus makes little sense to use Composer for it

Q: My tests need to run with eZ configured to use Redis/Memcached for cache (or other). Is it possible?

A: both Redis and Memcached are installed in the test container, and you can provide custom Symfony configuration that
   is only activated during testing, to make sure that any of those two is used.
   Otoh this has not been tested yet, and it is possible that you will need to start the Redis/Memcached service by hand.

Q: When I run `teststack start`, there is a long wait while the script says only `Waiting for ez ...` - can I troubleshoot
   what is going on at that time?

A: sure. Start a second shell, go to the project's folder and run `./teststack/teststack logs ez`

Q: Do you know of any bundles do make use of this one for testing, so that I can explore how they do it?

A: sure. At least the following ones: https://github.com/kaliop/ezobjectwrapper, https://github.com/kaliop-uk/ezmigrationbundle

Q: Are there other projects that you know of that have similar goals as this package?

A: certainly there are. Ones that I know of are f.e. https://github.com/Plopix/symfony-bundle-app-wrapper and
   https://github.com/g1a/composer-test-scenarios

Q: How are you testing this Test Stack itself?

A: Inception!!!
