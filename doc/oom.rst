Deploying ONAP using OOM
========================

Clone OOM beijing tag

.. code-block:: shell

   git clone https://gerrit.onap.org/r/oom --branch 2.0.0-ONAP ~/oom && cd ~/oom

Install helm

.. code-block:: shell

   curl https://storage.googleapis.com/kubernetes-helm/helm-v2.8.2-linux-amd64.tar.gz -o /tmp/helm-v2.8.2-linux-amd64.tar.gz && \
   cd /tmp && tar zxf /tmp/helm-v2.8.2-linux-amd64.tar.gz && sudo cp linux-amd64/helm /usr/local/bin && \
   rm -rfv linux-amd64 /tmp/helm-v2.8.2-linux-amd64.tar.gz

Configure the tiller service account

.. code-block:: shell

    cat > tiller-serviceaccount.yaml << EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
       name: tiller
       namespace: kube-system
    ---
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
      name: tiller-clusterrolebinding
    subjects:
    - kind: ServiceAccount
      name: tiller
      namespace: kube-system
    roleRef:
      kind: ClusterRole
      name: cluster-admin
      apiGroup: ""
    EOF

    kubectl -n kube-system delete deployment tiller-deploy
    kubectl -n kube-system delete serviceaccount tiller
    kubectl -n kube-system delete ClusterRoleBinding tiller-clusterrolebinding

    kubectl create -f tiller-serviceaccount.yaml
    helm init --service-account tiller

Optionally create a nexus proxy cache

.. code-block:: shell

    sudo docker run -d -p 5000:5000 --restart=unless-stopped --name registry -e REGISTRY_PROXY_REMOTEURL=https://nexus3.onap.org:10001 -e https_proxy=http://proxy.esl.cisco.com  registry