.. contents:: Table of contents

Overview
========

This project provides a flexible base for VM configurations.

Current `OXID eShop <http://www.oxid-esales.com/en/home.html>`_ development
environment is inspired by `PuPHPet <https://puphpet.com/>`_ and
`Phansible <http://phansible.com/>`_ projects.

Virtual environment is built using:

* `Vagrant <https://www.vagrantup.com/>`_ - virtual environment automation tool;
* `Ansible <http://www.ansible.com/>`_ - environment orchestration tool;
* `YAML <http://yaml.org/>`_ - solution configuration.

Final solution is composed of two repositories (*linked using git sub-modules*):

* `Base VM <https://github.com/OXID-eSales/oxvm_base>`_ - Current repository, Base LAMP stack.
* `eShop VM <https://github.com/OXID-eSales/oxvm_eshop>`_ - eShop specific configuration and roles.

Getting started
===============

Before proceeding with `Quick start`_ please ensure that the
`Dependencies`_ listed below are installed.

.. _`Dependencies`

Dependencies
------------

* `Vagrant <https://www.vagrantup.com/downloads.html>`_ (>=1.8.6)
* `VirtualBox <https://www.virtualbox.org/>`_ [#virtualbox_dependency]_ (>=4.2, except 5.1.8, see `#29 <https://github.com/OXID-eSales/oxvm_eshop/issues/29>`_; Windows users see `#32 <https://github.com/OXID-eSales/oxvm_eshop/issues/32>`__)
* `Git <https://git-scm.com/downloads>`_
* `OpenSSH <http://www.openssh.com/>`_ (*Only client part is needed*)
* Vagrant plugins:

  * ``vagrant plugin install vagrant-hostmanager vagrant-triggers``
  * ``vagrant plugin install vagrant-lxc`` (*If* `LXC <https://github.com/fgrehm/vagrant-lxc>`_ *will be used for provision process.*)
  * ``vagrant plugin install vagrant-parallels`` (*If* `Parallels <https://github.com/Parallels/vagrant-parallels>`_ *will be used for provision process.*)

.. _`Quick start`

Quick start
-----------

**Note for Windows users**: Use console with **Administrator privileges** to run vagrant commands!

* Clone out current repository:

.. code:: bash

  git clone https://github.com/OXID-eSales/oxvm_base.git

* Start the VM:

.. code:: bash

  cd oxvm_base
  vagrant up

* After successful provision process you can put your sources in the shared folder and access them at http://oxvm.local/

* If something doesn't work, see the `Troubleshooting`_ section.

.. [#virtualbox_dependency] VirtualBox is listed as dependency due to the fact that it is the default chosen provider for the VM. In case other providers will be used there is no need to install VirtualBox. Please refer to the list of possible providers in the configuration section to get more information.

Configuration
=============

Default virtual environment configuration should be sufficient enough to get
most projects up and running. However, it is possible to adjust
the configuration of the virtual environment to better match individual preferences.

All configuration changes should be done by overriding variables from:

* `default.yml <https://github.com/OXID-eSales/oxvm_base/blob/master/ansible/vars/default.yml>`_ - base vm variables;

These overridden values must be placed in ``personal.yml``
[#personal_git_ignore]_ file at the root level of current repository.

For the overridden values to take effect please run ``vagrant provision``. If
the changes are related to the shared folder use ``vagrant reload``. In case the
provision process will start to show any kind of errors, please try to use
``vagrant destroy && vagrant up`` for the process to start over from a clean
state.

To double check the merged version of configuration just run ``vagrant config``.

Hint: you have to care for the syntax/semantics for yourself. So, if you get an error while ``vagrant provision``
your personal.yml is the start point for troubleshooting.
Hint: Check if every entry has a value. At the moment no empty entries will work.

Examples
--------

Below is a list of possible frequent changes which are typically done after
cloning this repository.

One can just copy and paste the example snippets from the list below to the
``personal.yml`` file at the root of this repository.

Use NFS for shared-folder
^^^^^^^^^^^^^^^^^^^^^^^^^

If `LXC <https://en.wikipedia.org/wiki/LXC>`_ is not available on your host system the best (so far) method to
share your application folder would be to use `NFS <https://en.wikipedia.org/wiki/Network_File_System>`_.

In order to trigger NFS usage inside the VM one has to add the following configuration:

.. code:: yaml

  ---
  vagrant_local:
    vm:
      app_shared_folder:
        sync_type: nfs

Beware that in order for this to work your host system must support NFS server:

* OS X/macOS has this integrated out-of-the-box
* Various GNU/Linux distributions might require additional setup:

  * `Ubuntu <https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-16-04>`_
  * `Debian <https://wiki.debian.org/NFSServerSetup>`_
  * `RHEL/CentOS <https://www.howtoforge.com/tutorial/setting-up-an-nfs-server-and-client-on-centos-7/>`_
  * `ArchLinux <https://wiki.archlinux.org/index.php/NFS>`_

Be aware that NFS also has it's own limitations:

* No server is available for Microsoft Windows
* NFS uses network stack to share data
* NFS does not propagate file change events to the guest system
* Sometimes NFS is complicated to setup/troubleshoot in a non-standard environment

Change PHP version
^^^^^^^^^^^^^^^^^^

By default latest PHP version found in ubuntu repository is installed.

When PHP version is specified, `PHPBrew <https://github.com/phpbrew/phpbrew>`_ is installed and used for switching between versions.
Requested version will be either built on the fly or downloaded from assets [#assets_repository]_ repository.

.. code:: yaml

  ---
  php:
    version: 5.3

Keep in mind that by default this setting only affects the CLI interface of PHP,
in order to change the PHP version for Apache, please apply the following
additional commands:

.. code:: bash

  sudo cp /etc/apache2/mods-available/php5.6.conf /etc/apache2/mods-available/php5.conf
  sudo a2dismod php5.6
  sudo a2enmod php5
  phpswitch 5.3 # or 5.4, 5.5, 5.6, 7.0, 7.1

To disable downloading of cached versions from assets repository, set ``cache_repository`` to empty value.
Alternatively it is possible to build your own PHP packages and place them into any svn repository.

Only when php version is specified, PHPBrew will be installed so those commands became available inside VM:

* ``phpbrew list`` - lists installed PHP versions
* ``phpbrew update --old`` - Updates PHP versions list with old php versions
* ``phpbrew known`` - lists available PHP versions
* ``phpbuild [version]`` - builds PHP version
* ``phpswitch [version]`` - switch PHP version
* ``phpswitch off`` - switch back to default PHP version

When versions is downloaded from assets repository, phpbrew will not have its source code and therefore will not be able to build php extensions.
To download PHP source run this command with full php version specified:

.. code:: bash

  phpbrew download [phpversion] && tar jxf ~/.phpbrew/distfiles/php-[phpversion].tar.bz2 -C ~/.phpbrew/build/

Change MySQL version
^^^^^^^^^^^^^^^^^^^^

MySQL versioning is not yet automated via Ansible, in order to change the
version of MySQL service, please apply the following commands after calling
``vagrant ssh``:

.. code:: bash

  wget http://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
  sudo dpkg -i mysql-apt-config_0.8.7-1_all.deb
  # Choose MySQL version to install
  sudo apt-get update
  sudo apt-get install mysql-server

Change VM provider
^^^^^^^^^^^^^^^^^^

Change VM provider from VirtualBox (*default*) to LXC.
A list of available and tested providers [#list_of_providers]_:

- `virtualbox <https://www.virtualbox.org/>`_ - Default provider which is free
  to use and available on all major operating systems;
- `lxc <https://linuxcontainers.org/>`_ [#lxc_provider]_ - Operating system
  level virtualization which vastly improves I/O performance compared to
  para-virtualization solutions;
- `parallels <http://www.parallels.com/eu/>`_ [#parallels_provider]_ - Commercial
  VM provider for OS X.

.. code:: yaml

  ---
  vagrant_local:
    vm:
      provider: lxc

Change shared folder path
^^^^^^^^^^^^^^^^^^^^^^^^^

Change the default application shared folder from ``www`` to local path
``/var/www``.

.. code:: yaml

  ---
  vagrant_local:
    vm:
      app_shared_folder:
        source: /var/www
        target: /var/www

Define github token for composer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Provide OAuth token from github for composer so that the access API limit could
be removed [#github_token]_.

.. code:: yaml

  ---
  php:
    composer:
      github_token: example_secret_token

Change ubuntu repository mirror url
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Change the default ubuntu repository mirror url from ``http://de.archive.ubuntu.com/ubuntu/``
to ``http://us.archive.ubuntu.com/ubuntu/``.

.. code:: yaml

  ---
  server:
    apt_mirror: http://us.archive.ubuntu.com/ubuntu/

Change virtual host
^^^^^^^^^^^^^^^^^^^

Change the default virtual host from ``www.default.local`` to
``www.myproject.local``.

.. code:: yaml

  ---
  vagrant_local:
    vm:
      aliases:
        - www.myproject.local

Change the display mode of errors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default the `display_errors` option is turned on. To change
the behavior you can use:

.. code:: yaml

  ---
  php:
    display_errors: Off

Change MySQL password
^^^^^^^^^^^^^^^^^^^^^

Change the default MySQL user password from ``oxid`` to ``secret``.

.. code:: yaml

  ---
  mysql:
    password: secret

Setting up Varnish
^^^^^^^^^^^^^^^^^^

Trigger Varnish installation via:

.. code:: yaml

  ---
  varnish:
    install: true

The above change will only trigger installation of Varnish with the distributed
default configuration ``default.vcl``, adapt this to your needs.

If you change the parameter for a running VM you can use ``vagrant provision`` to trigger the installation.

Trigger Selenium installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trigger `Selenium <http://www.seleniumhq.org/>`_ installation so that it can be
used to run Selenium tests with the help of
`OXID testing library <https://github.com/OXID-eSales/testing_library.git>`_.

.. code:: yaml

  ---
  selenium:
    install: true

Together with Selenium, a vnc server is installed in order to connect via remote
display. Suitable clients are e.g. ``vinagre`` on Linux or the built-in vnc
client of OS X.

Trigger IonCube integration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trigger `IonCube <http://www.ioncube.com/>`_ integration so that it can be
used to decode the encoded files.

.. code:: yaml

  ---
  ioncube:
    install: true

Customize email monitoring integration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Integration of `Mailhog <https://github.com/mailhog/MailHog>`_ allows to monitor
e-mail activity from the eShop. List of e-mails could be seen at:
http://www.default.local/mail/ or http://www.oxideshop.local/mail/

Possible configuration options for Mailhog:

* ``web_port`` - web UI port (``8025`` is the default value which means that the
  UI can be accessed by the following URL: http://www.default.local:8025/)
* ``smtp_port`` - SMTP server port (``1025`` is the default value)
* ``web_alias`` - an URL alias for the default virtual host to act as a proxy
  for web UI of mailhog (``/mail/`` is the default value which means that the UI
  can be access by the following URL: http://www.default.local/mail/)

An example configuration which changes web UI port to ``8024``, SMTP port to
``1026`` and alias to ``/emails/``:

.. code:: yaml

  ---
  mailhog:
    web_port: 8024
    smtp_port: 1026
    web_alias: /emails/

Mailhog is installed by default as it has ``install: true`` option in the
default configuration file. In order to disable email monitoring please use the
following configuration snippet:

.. code:: yaml

  ---
  mailhog:
    install: false

Customize MySQL administration web app integration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Integration of `Adminer <https://github.com/vrana/adminer>`_ allows to access
MySQL administrative tasks and data through web alias ``adminer`` at:
http://www.default.local/adminer/ or http://www.oxideshop.local/adminer/

Integration of
`Adminer editor <https://github.com/vrana/adminer/tree/master/editor>`_ allows
to access and modify MySQL data through web alias ``adminer_editor`` at:
http://www.default.local/adminer_editor/ or http://www.oxideshop.local/adminer_editor/

Possible configuration options for **Adminer** and **Adminer editor**:

* ``pkg_url`` - An URL which points to the compiled PHP version of the
  application
* ``web_alias`` - An alias used to access the application (Default value is
  ``adminer``/``adminer_editor``, which means that in order to access it one has
  to open http://www.default.local/adminer/ /
  http://www.default.local/adminer_editor/)
* ``pkg_sha256`` - A SHA-256 hash of file contents downloaded from resource
  defined in ``pkg_url``

**Adminer** and **Adminer editor** are installed by default as they have
``install: true`` option in the default configuration file. In order to disable
these tools please use the following configuration snippet:

.. code:: yaml

  ---
  adminer:
    install: false
  adminer_editor:
    install: false

Keep in mind that your MySQL credentials will be already present in the login
page and there is **no need to enter the login data manually**. The following
variables are used to gain MySQL credentials:

* ``mysql.user`` - User name which has access to the created database
* ``mysql.password`` - Password of previously mentioned user
* ``mysql.database`` - Name of the newly created database

Composer parallel install plugin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The composer parallel install plugin
`hirak/prestissimo <https://github.com/hirak/prestissimo>`_ is enabled by default.
In order to disable it please use the following snippet:

.. code:: yaml

  ---
  php:
    composer:
      prestissimo:
        install: false

.. [#personal_git_ignore] ``personal.yml`` configuration file is already included in ``.gitignore`` and should not be visible as changes to the actual repository.
.. [#assets_repository] Repository with some already prebuilt versions of php for faster installation.
.. [#list_of_providers] VM solutions from `VMWare <http://www.vmware.com/>`_, such as `workstation <http://www.vmware.com/products/workstation>`_ and `fusion <http://www.vmware.com/products/fusion>`_ were not yet adapted or tested with our current configuration of VM.
.. [#lxc_provider] Keep in mind that LXC provider is only available for GNU/Linux based operating systems. In order to start using this provider with vagrant a plugin must be installed for it (``vagrant plugin install vagrant-lxc``). So far it has been only tested with Ubuntu based OS with lxc package installed (``sudo apt-get install lxc``).
.. [#parallels_provider] A vagrant plugin must be installed (``vagrant plugin install vagrant-parallels``) in order to use vagrant with Parallels.
.. [#github_token] By default github has API access limits set for anonymous access. In order to overcome these limits one has to create a github token, which could be done as described in: https://help.github.com/articles/creating-an-access-token-for-command-line-use/

Guides
======

List of guides for working with VM:

How to update the VM
--------------------

* Open VM directory:

.. code:: bash

  cd oxvm_base

* Destroy old VM:

.. code:: bash

  vagrant destroy

* Update eShop VM:

.. code:: bash

  git pull

* Start VM:

.. code:: bash

  vagrant up

How to provision individual parts
---------------------------------

In order to provision only individual part of the VM one can simply use
``ANSIBLE_TAGS`` environment variable. Consider the following examples:

.. code:: bash

  # Provision PHP and MySQL parts only
  ANSIBLE_TAGS=php,mysql vagrant provision

  # Provision OXID eShop related part only
  ANSIBLE_TAGS=eshop vagrant provision

Ansible tags are marked inside ``roles`` directories. To get a list of them try running the following command:

.. code:: bash

  grep -r -A 2 --include="*.yml" "tags\:" .


Troubleshooting
===============

List of troubleshooting items:

Provision process hangs on "Run composer install" task
------------------------------------------------------

During the provision process (*which could be invoked implicitly by*
``vagrant up`` *or explicitly by* ``vagrant provision``) a task ``Run composer
install`` might hang (*waiting for time-out*) because github access API limit
has been reached and ``composer`` is asking for github account username/password
which could resolve the API limit. ``Ansible`` will not provide this information
to ``STDOUT`` or ``STDERR`` so it will look like the task just hanged.

Since there are no options to provide username/password for this particular task
one could just use a github API token which will allow to overcome the API
access limit.

How to create and configure a github token is described in
`Define github token for composer <#define-github-token-for-composer>`_ chapter.

Error from `Unit_Admin_ModuleListTest::testRender()` method while testing eShop
-------------------------------------------------------------------------------

Older versions of eShop contains a very strict test inside
`Unit_Admin_ModuleListTest::testRender()` method which tries to match the exact
list of available modules. The test method might fail because VM includes SDK
components and some of them are actual modules (*which will result in modified
list of available modules*).

This is a known issue which is fixed in the development and new upcoming
releases of eShop.

To check which shop is compatible with testing library please refer to `compatibility list <https://github.com/OXID-eSales/testing_library/tree/b-1.0#compatibility-with-oxid-shops>`_.

Browser shows "Zend Guard Run-time support missing!"
----------------------------------------------------

This message will only appear if a
`Zend Guard <https://www.zend.com/en/products/zend-guard>`_ encoded eShop
package is being used. In order to solve the issue one has to install
`Zend Guard Loader <http://www.zend.com/en/products/loader/downloads>`_ which
will decode the encoded PHP files on execution.

To install and enable Zend Guard Loader PHP extension add the following configuration:

.. code:: yaml

  php:
    zendguard:
      install: true

Keep in mind that this extension will only work with the default PHP version, i.e.
at the moment the use of extenion with phpbrew is not automated.

To install and enable Zend Guard Loader PHP extension manually inside the VM:

.. code:: bash

  # From host (local machine)
  vagrant ssh

  # From guest (virtual machine)
  cd /usr/lib/php/20131226/
  sudo wget https://github.com/OXID-eSales/oxvm_assets/blob/master/zend-loader-php5.6-linux-x86_64.tar.gz?raw=true -O zend.tar.gz
  sudo tar zxvf zend.tar.gz
  sudo cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so ./
  sudo cp zend-loader-php5.6-linux-x86_64/opcache.so ./zend_opcache.so
  cd /etc/php/5.6/mods-available/
  sudo sh -c 'echo "zend_extension=ZendGuardLoader.so" > zend.ini'
  sudo sh -c 'echo "zend_extension=zend_opcache.so" >> zend.ini'
  sudo phpdismod opcache
  sudo phpenmod zend
  sudo service apache2 restart

Keep in mind that different PHP version needs different version of Zend Guard
Loader extension. List of possible extension versions can be found in
`oxvm_assets <https://github.com/OXID-eSales/oxvm_assets>`_ repository.

More information on how to install and configure Zend Guard Loader can be found
at: http://files.zend.com/help/Zend-Guard/content/installing_zend_guard_loader.htm

On Windows machines, getting "requires a TTY"
---------------------------------------------

The example of error message:

.. code:: bash

  { oxvm_base } master » vagrant destroy
  Vagrant is attempting to interface with the UI in a way that requires
  a TTY. Most actions in Vagrant that require a TTY have configuration
  switches to disable this requirement. Please do that or run Vagrant
  with TTY.

Please check answers on stackoverflow for your specific case: http://stackoverflow.com/questions/23633276/vagrant-is-attempting-to-interface-with-the-ui-in-a-way-that-requires-a-tty

Selenium tests do not run after VM was destroyed: error "Session not started"
-----------------------------------------------------------------------------

Restart selenium server is needed and can be done with command:

.. code:: bash

    sudo /etc/init.d/selenium restart

Composer returns "ProcessTimedOutException"
-------------------------------------------

In case there are Internet connection issues composer might take longer time to download
various packages and hit ``ProcessTimeOutException``. In order to avoid that configuration can
be updated to increase this time-out:

.. code:: yaml

    php:
      composer:
        timeout: 3000

On Windows machines, fails to install vagrant-hostmanager plugin
----------------------------------------------------------------

Using user name with space in it leads to an error message:

::

  The directory where plugins are installed (the Vagrant home directory)
  has a space in it. On Windows, there is a bug in Ruby when compiling
  plugins into directories with spaces. Please move your Vagrant home
  directory to a path without spaces and try again.

Possible solution:

- Install Vagrant in a directory which has no spaces in the path.
- Define Windows Environment Variable ``%VAGRANT_HOME%`` to hold path to the directory ``Path_to_Vagrant\bin``
