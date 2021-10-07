This playbook will install virtualized clusters with the desired amount of nodes, and desired cluster type (sno or standard).

## Deploying SNO on Sopke cluster 

You will find inventory sample **hosts.sno.yaml.sample** file for deploying SNO cluster under inventory directory.
Please fill the inventory vars as needed. Also, update MAC address and IPs to reflect your environment at **files/nmstate_ipv6.yaml**.

Once the changes have been made, you can retrieve the available tags by passing --list-tags and currently available tags are:

    TASK TAGS: [add-extra-workers, create-extra-partition, create-vms, deploy-cluster-with-policy, generate-manifests, install-requirements, mirror-release-image]

you can launch the playbook to provision a spoke cluster with skipping add--extra-workers for deploying SNO as:

    ansible-playbook -i inventory/hosts.sno.yaml.sample playbook.yml --skip-tags=add-extra-workers

The successful execution of playbook will create the virtual machine and will generate and apply the final manifests for creating the cluster. Once the cluster installation is initiated, you will see that as “Creating” on the ACM clusters section.

You need to wait until you retrieve Installed to true on :

    oc get clusterdeployment -n ${CLUSTER_NAME}

Once finished, you can retrieve the secrets from:

    oc get secret ${CLUSTER_NAME}-admin-kubeconfig -n ${CLUSTER_NAME} -o json | jq -r '.data.kubeconfig' | base64 -d > /tmp/sno_spoke_kubeconfig

Afterwards, you can export configuration file and can do relevant checks by following commands:

    export KUBECONFIG=/tmp/sno_spoke_kubeconfig

    oc get nodes -o wide
    oc get co
    oc get clusterversion

