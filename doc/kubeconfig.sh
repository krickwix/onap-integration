
mkdir -p ~/.kube
kubernetes_admin_client_certificate_data=$(cfy deploy out kube|grep -A2 kubernetes-admin_client_certificate_data|grep Value|cut -d: -f2|awk '{$1=$1};1')
kubernetes_admin_client_key_data=$(cfy deploy out kube|grep -A2 kubernetes-admin_client_key_data|grep Value|cut -d: -f2|awk '{$1=$1};1')
kubernetes_cluster_master_ip=$(cfy deploy out kube|grep -A2 kubernetes_cluster_master_ip|grep Value|cut -d: -f2|awk '{$1=$1};1')
kubernetes_certificate_authority_data=$(cfy deploy out kube|grep -A2 kubernetes_certificate_authority_data|grep Value|cut -d: -f2|awk '{$1=$1};1')

cat > ~/.kube/config << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: "$kubernetes_certificate_authority_data"
    server: https://$kubernetes_cluster_master_ip:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: "$kubernetes_admin_client_certificate_data"
    client-key-data: "$kubernetes_admin_client_key_data"
EOF

