Installing a Kubernetes cluster
===============================

.. code-block:: shell

   sudo yum -y install docker && sudo systemctl enable docker && sudo systemctl start docker 

Installing Cloudify
###################

Install the cloudify manager

.. code-block:: shell

    wget http://repository.cloudifysource.org/cloudify/4.3.2/ga-release/cloudify-docker-manager-4.3.2ga.tar -O /tmp/cloudify-docker-manager-4.3.2ga.tar
    sudo docker load -i /tmp/cloudify-docker-manager-4.3.2ga.tar
    sudo docker run --name cfy_manager -d --restart unless-stopped -v /sys/fs/cgroup:/sys/fs/cgroup:ro --tmpfs /run --tmpfs /run/lock --security-opt seccomp:unconfined --cap-add SYS_ADMIN --network host docker-cfy-manager:latest
    myip=$(ip a |grep eth0|grep global|awk {'print $2'}|cut -d/ -f1)

Install the Cloudify CLI and create a profile

.. code-block:: shell

   curl http://repository.cloudifysource.org/cloudify/4.3.2/ga-release/cloudify-cli-4.3.2ga.rpm -o /tmp/cloudify-cli-4.3.2ga.rpm && sudo rpm -ivh /tmp/cloudify-cli-4.3.2ga.rpm && rm -v /tmp/cloudify-cli-4.3.2ga.rpm
   cfy profiles use $myip -u admin -p admin -t default_tenant

Deploying the kubernetes cluster
################################

Install the required plugins into the deployed cloudify manager

.. code-block:: shell

   cfy plugins upload -y https://github.com/cloudify-cosmo/cloudify-diamond-plugin/releases/download/1.3.8/plugin.yaml https://github.com/cloudify-cosmo/cloudify-diamond-plugin/releases/download/1.3.8/cloudify_diamond_plugin-1.3.8-py27-none-linux_x86_64-centos-Core.wgn && \
   cfy plugins upload -y http://www.getcloudify.org/spec/fabric-plugin/1.5.1/plugin.yaml http://repository.cloudifysource.org/cloudify/wagons/cloudify-fabric-plugin/1.5.1/cloudify_fabric_plugin-1.5.1-py27-none-linux_x86_64-centos-Core.wgn && \
   cfy plugins upload -y https://github.com/cloudify-incubator/cloudify-utilities-plugin/releases/download/1.7.1/plugin.yaml https://github.com/cloudify-incubator/cloudify-utilities-plugin/releases/download/1.7.1/cloudify_utilities_plugin-1.7.1-py27-none-linux_x86_64-centos-Core.wgn && \
   cfy plugins upload -y https://github.com/cloudify-cosmo/cloudify-openstack-plugin/releases/download/2.9.0/plugin.yaml https://github.com/cloudify-cosmo/cloudify-openstack-plugin/releases/download/2.9.0/cloudify_openstack_plugin-2.9.0-py27-none-linux_x86_64-centos-Core.wgn && \
   cfy plugins upload -y https://github.com/cloudify-incubator/cloudify-kubernetes-plugin/releases/download/2.3.1/plugin.yaml https://github.com/cloudify-incubator/cloudify-kubernetes-plugin/releases/download/2.3.1/cloudify_kubernetes_plugin-2.3.1-py27-none-linux_x86_64-centos-Core.wgn

.. code-block:: shell

    ssh-keygen -f onapadmin -t rsa -P ""

    cfy secrets create -s 432fc99f-f997-4de6-9b30-1778c7e44b68 centos_core_image
    cfy secrets create -s admin cfy_password
    cfy secrets create -s default_tenant cfy_tenant
    cfy secrets create -s admin cfy_user
    cfy secrets create -s public external_network_name
    cfy secrets create -s 07039025-149c-4093-9047-b24efbbee924 large_image_flavor
    cfy secrets create -s provision-net public_network_name
    cfy secrets create -s provision-subnet public_subnet_name
    cfy secrets create -s regionOne region
    cfy secrets create -s onap-integration-router router_name
    cfy secrets create -s cisco123 keystone_password
    cfy secrets create -s onap-integration keystone_tenant_name
    cfy secrets create -s http://10.60.18.18:5000/v2.0 keystone_url
    cfy secrets create -s onapuser keystone_username
    cfy secrets create -f onapadmin agent_key_private
    cfy secrets create -f onapadmin.pub agent_key_public

Install the kubernetes blueprint

.. code-block:: shell

    cfy install \
    https://github.com/cloudify-examples/simple-kubernetes-blueprint/releases/download/cloudify-kubernetes-4.3.1-16/cloudify-kubernetes-4.3.1-16.tar.gz \
    --blueprint-filename openstack.yaml \
    --blueprint-id kube

Optionally scale the kubernetes cluster

.. code-block:: shell

    cfy executions start -d k8s_node_dep -p "scalable_entity_name=k8s_node_scaling_tier;delta=4" scale

Build the kube config file

.. literalinclude:: kubeconfig.sh
   :language: shell

Install kube 

.. code-block:: shell

    echo "
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    " | sudo tee /etc/yum.repos.d/kubernetes.repo
    sudo yum install -y kubectl
