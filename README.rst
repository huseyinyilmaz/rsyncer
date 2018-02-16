rsyncer
=======


Rsyncer is a code-sync tool that syncs project code from local filesystem to development server. It can be used in 2 different ways.

Use with command-line options
-----------------------------

::

   rsyncer --source=/Users/huseyin/testproject/ --destination=huseyin@huseyin.testserver.com:/home/huseyin/testproject --exclude=.git --exclude static/dist


Use with configuration file
---------------------------

To use it with configuration file, first a configuratoin file named "~/.rsyncer_config.yaml" needs to be created on home directory.

Here is a sample for that file:

::

   ---
   projects:
     - name: testproject
       source: /Users/huseyin/testproject/
       destination: huseyin@huseyin.testserver.com:/home/huseyin/testproject
       excludes:
         - .git
         - static/dist

     - name: testproject_js_only
       source: /Users/huseyin/testproject/static/js/
       destination: huseyin@huseyin.testserver.com:/home/huseyin/testproject/static/js


After configuration file is in place, we can call the sync command with project name.

::

   $ rsyncer testproject
   ...
   $ rsyncer testproject_js_only
   ...

It is also possible to change project's configuration on call time.

::

   # exclude all files with .jsx extension.
   $ rsyncer testproject_js_only --exclude="*.jsx" --source:/Users/huseyin/testproject2/static/js/


How to build
------------

In order to build, you need to have haskell-stack environment already installed

::

   # on mac:
   $ brew install haskell-stack

After that, you can build and install the project:

::

   # to build:
   $ stack build
   # to install:
   $ stack install

This will install the binary on ~/.local/bin/rsyner folder you need to either carry your binary somewhere in your path or add ~/.local/bin directory to your path.
