This playbook will install virtualized clusters with the
desired amount of nodes, and desired cluster type (sno or
standard). You will find inventory samples for both types.
Please fill the inventory vars as needed.

You need to wait until you retrieve Installed on :

    oc get clusterdeployment/${CLUSTER_NAME}-deployment -n assisted-installer

Once finished, you can retrieve the secrets from:

    oc get secret ${CLUSTER_NAME}-deployment-admin-kubeconfig -o json | jq -r '.data.kubeconfig' | base64 -d > /tmp/sno_spoke_kubeconfig

    export KUBECONFIG=/tmp/sno_spoke_kubeconfig

    oc get nodes -o wide
    oc get co
    oc get clusterversion

