Deploying a PNDA cluster
========================

.. code-block:: shell

    git clone -b develop https://github.com/krickwix/pnda-cli ~/pnda-cli
    cd ~/pnda-cli

.. code-block:: shell

    cp pnda_env_example.yaml pnda_env.yaml
    vi pnda_env.yaml
    cp ~/onapadmin onapadmin.pem

.. code-block:: shell

   cd ~/pnda-cli/cli
   sudo yum -y install python-virtualenv
   virtualenv os
   . os/bin/activate
   pip install -r requirements.txt

.. code-block:: shell

   ./pnda-cli.py -e anion -k 1 -n 1 -s onapadmin -f pico create

