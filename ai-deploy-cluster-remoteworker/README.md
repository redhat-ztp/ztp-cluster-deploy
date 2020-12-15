This is a set of playbooks to automate the deployment of Openshift cluster and remote worker node, using Assisted Installer
and Small ISO.

- Requirements:

    - Podman.
    - Ansibale.
        - Ansibale modules: community.libvirt, containers.podman and containers.general

- Steps:

    1- git clone the ztp-cluster-deploy repo

    2- go to ai-deploly-cluster-remoteworker dir

    3- You need make a copy inventory/hosts.sample file and name it hosts under same directory.

    4- Modify the [all:vars] section at inventory/hosts file based on your HW env.

    5- Start the deployment with prepare-environment tag.

        $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=prepare-environment

    6- Make sure that AI pod has been created and the http server are running.

        $ sudo systemctl status httpd
          httpd.service - The Apache HTTP Server
            Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
            Active: active (running) since Mon 2020-12-14 14:21:12 EST; 5h 55min ago

        - Note: We use the httpd to host and provide the generated iso files during installation.
         You can use any other HTTP server in your env however you will need to adjuest configurations in the inventory/hosts file.

        $ sudo podman ps
        CONTAINER ID  IMAGE                                          COMMAND               CREATED      STATUS          PORTS                   NAMES
        2a9f6e4056a8  k8s.gcr.io/pause:3.2                                                 6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  2ae5adf6da27-infra
        603d56566a6b  quay.io/ocpmetal/postgresql-12-centos7:latest  run-postgresql        6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  db
        a4d2a578fe32  quay.io/ocpmetal/assisted-service:latest       /assisted-service     6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  installer
        f8ab3586816f  quay.io/ocpmetal/ocp-metal-ui:latest           /opt/bitnami/scri...  6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  ui

        - Note: Disable firewalld in order to avoid any tcp ports blocking issues

    7- Based on your env and your machine intf use nmcli command to set the network-config under /opt/ dir

        $ sudo mkdir /opt/network-config
        Note: Then you can config your machine as below
        $ cat /opt/network-config/etc/NetworkManager/system-connections/eno1.nmconnection 
        [connection]
        id=static
        type=ethernet
        interface-name=eno1
        permissions=
        
        [ethernet]
        mac-address-blacklist=
        
        [ipv4]
        method=auto
        dhcp-hostname=cluster.local
        dhcp-send-hostname=true
        
        [ipv6]
        method=ignore

    8- Finally you can execute the rest of installation steps as below.

        $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --skip-tags=prepare-environment

        Note: Based on your env the installation should take around 1h to 1:30h
        For any error appears you can re-run each installation step by its tag name.

        $ cat playbook.yml 
        ---
        - name: Deploy clusters with assisted installer
          hosts: provisioner
          roles:
            - role: prepare-environment
              tags: prepare-environment
            - role: create-cluster
              tags: create-cluster
            - role: enroll-hosts
              tags: enroll-hosts
            - role: deploy-cluster
              tags: deploy-cluster
            - role: expose-endpoints
              tags: expose-endpoints
            - role: create-cluster-day2
              tags: create-cluster-day2
            - role: modify-iso-day2
              tags: modify-iso-day2
            - role: add-remote-worker
              tags: add-remote-worker
            - role: deploy-cluster-day2
              tags: deploy-cluster-day2

        Just specify the tag as we did in step 5

- After deployment:

    - In the installation node run the below commands to check the created clusters and nodes. You should see similar output.

            $ aicli list cluster

            +-------------+--------------------------------------+--------------+----------------------------+
            |   Cluster   |                  Id                  |    Status    |         Dns Domain         |
            +-------------+--------------------------------------+--------------+----------------------------+
            |    cnfde2   | eaf6b793-d2b0-496d-827a-93abd8e041af |  installed   | ptp.lab.eng.bos.redhat.com |
            | cnfde2-day2 | 904a1551-cec1-4ea3-ae68-ff430ef40521 | adding-hosts | ptp.lab.eng.bos.redhat.com |
            +-------------+--------------------------------------+--------------+----------------------------+

            $ aicli list hosts

            +-------------------------------------------+-------------+--------------------------------------+---------------------------+--------+---------------+
            |                    Host                   |   Cluster   |                  Id                  |           Status          |  Role  |       Ip      |
            +-------------------------------------------+-------------+--------------------------------------+---------------------------+--------+---------------+
            |     cnfde7.ptp.lab.eng.bos.redhat.com     | cnfde2-day2 | 3eedcafb-1558-1a71-5c35-afa338e0730a | added-to-existing-cluster | worker |  10.16.231.7  |
            | dhcp16-231-115.ptp.lab.eng.bos.redhat.com |    cnfde2   | 6e01b4d4-8fa9-40b4-b477-8a4ac66c5826 |         installed         | master | 10.16.231.115 |
            | dhcp16-231-152.ptp.lab.eng.bos.redhat.com |    cnfde2   | 1a7bf1ff-2c16-4653-8d8d-2e68f2311660 |         installed         | master | 10.16.231.152 |
            | dhcp16-231-154.ptp.lab.eng.bos.redhat.com |    cnfde2   | e6d260ca-3a4b-4af6-8edd-478d90591f39 |         installed         | master | 10.16.231.154 |
            +-------------------------------------------+-------------+--------------------------------------+---------------------------+--------+---------------+

    - You can download the kubeconfig of your cluster using the command below

            $ aicli download installconfig {YOUR_CLUSTER_NAME} --path ~/

    - Use the kubeconfig with OC command to check the openshift cluster nodes and custome resources

            $ oc get csr
 
            NAME        AGE     SIGNERNAME                                    REQUESTOR                                                                   CONDITION
            csr-22tk7   13h     kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
            csr-2cfh9   18h     kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
            csr-4557s   7h27m   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
            csr-49ccv   10h     kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
            

        Note: As you can see there are multipale operators need to be approved in order to finaliz the setup. Run the below command to approve all pending operators.

            $ oc get csr -o name | xargs oc adm certificate approve

            certificatesigningrequest.certificates.k8s.io/csr-22tk7 approved
            certificatesigningrequest.certificates.k8s.io/csr-2cfh9 approved
            certificatesigningrequest.certificates.k8s.io/csr-4557s approved
            certificatesigningrequest.certificates.k8s.io/csr-49ccv approved
            certificatesigningrequest.certificates.k8s.io/csr-4k2td approved

        Now check the cluster nodes using the below command, You should have 3 master nodes and 1 worker node.

            $ oc get nodes

            NAME                                        STATUS   ROLES           AGE     VERSION
            cnfde7.ptp.lab.eng.bos.redhat.com           Ready    worker          19h     v1.19.0+9f84db3
            dhcp16-231-115.ptp.lab.eng.bos.redhat.com   Ready    master,worker   20h     v1.19.0+9f84db3
            dhcp16-231-152.ptp.lab.eng.bos.redhat.com   Ready    master,worker   20h     v1.19.0+9f84db3
            dhcp16-231-154.ptp.lab.eng.bos.redhat.com   Ready    master,worker   20h     v1.19.0+9f84db3
