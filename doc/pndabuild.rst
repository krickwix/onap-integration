Building the PNDA deployment components
=======================================

The repository https://github.com/pndaproject/pnda contains the tools necessary
to build the components required for a PNDA deployment.

Install git if necessary

.. code-block:: shell

   sudo yum -y install git

Start by getting the repository

.. code-block:: shell

   git clone https://github.com/pndaproject/pnda ~/pnda

As a precaution, deinstall git and its dependencies

.. code-block:: shell

   sudo yum -y remove git

Get into the cloned directory

.. code-block:: shell

   cd ~/pnda

Package mirror
##############

Get into the mirror building tools subdirectory

.. code-block:: shell

   cd ~/pnda/mirror

Start building the mirror as a super-user

.. code-block:: shell

   sudo ./create_mirror_rpm.sh && sudo ./create_mirror_misc.sh && \
   sudo ./create_mirror_hdp.sh && sudo ./create_mirror_python.sh && \
   sudo ./create_mirror_apps.sh

PNDA apps
#########

Get into the pnda build subdirectory

.. code-block:: shell

   cd ~/pnda/build

You should still be a super-user to install the base tools

.. code-block:: shell

    echo "127.0.1.1 $(hostname)"|sudo tee -a /etc/hosts
    sudo ./install-build-tools.sh

Start building the pnda apps

.. code-block:: shell

   . set-pnda-env.sh
   ./build-pnda.sh BRANCH develop

Serving the result of the build
###############################

.. code-block:: shell

   sudo -s
   mkdir /srv/pnda_repo && \
   cp -av ~/pnda/mirror/mirror-dist/* /srv/pnda_repo && \
   cp -av ~/pnda/build/pnda-dist/* /srv/pnda_repo

One easy way to serve the packages is to use an http server.

.. code-block:: shell

   yum -y install docker && \
   docker run --rm -v /srv/pnda_repo:/usr/local/apache2/htdocs/ -d -p 8080:80 httpd:alpine

The http server should now be serving the packages, apps and archive necessary to the 
pnda deployment process.

Putting all the shit together
#############################


.. literalinclude:: build_the_shit.sh
   :language: shell

