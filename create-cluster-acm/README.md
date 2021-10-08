This playbook will install virtualized clusters with the desired amount of nodes, and desired cluster type (sno or standard).

## Deploying SNO on Spoke cluster 

You will find inventory sample **hosts.sno.yaml.sample** file for deploying SNO cluster under inventory directory.
Please fill the inventory vars in the file as needed. Also, update MAC address and IPs to reflect your environment at **files/nmstate_ipv6.yaml**.

Once the changes have been made, you can retrieve the available tags by passing *--list-tags* and these tags can be executed step by step by passing *--tags=<tag_name>* with the ansible-playbook command.

The available tags are : 

    TASK TAGS: [ install-requirements, create-vms, generate-manifests, create-extra-partition, mirror-release-image, deploy-cluster-with-policy, add-extra-workers]

* install-requirements role consists of building policygenrator and installing few packages including sushy-tools

* create-vms role creates VM with desired cpu, memory, network and disk requirements

* generate-manifests is responsible for creating ntp service

* create-extra-partition role creates an extra partition for backup and recovery of cluster resources

* mirror-release-image role creates mirror images for spoke cluster and deploy imageset
 
* deploy-cluster-with-policy creates namespaces and secrets, download source CRs for policygenerator to generate actual CRs based on siteconfig to be applied in the cluster

* add-extra-workers role adds extra workers on the cluster if required


You can launch the playbook to provision a spoke cluster as:

    ansible-playbook -i inventory/hosts.sno.yaml.sample playbook.yml

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



## Deploying 3 Node standard clusters 

You can use **hosts.yaml.sample** file under /inventory to create 3 node clusters, the available tags are the same as mentioned above. For **Day 2** operations, you can use the **hosts.extraworkers.yaml.sample** file to add extra workers as needed. Additionally, for example, if you want to have 3 masters and 2 workers node, you can utilize **hosts.5nodes.yaml** file to launch the cluster deployment