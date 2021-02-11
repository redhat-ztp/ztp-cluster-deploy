This is a set of playbooks to automate the deployment of Openshift cluster with single node footprint,
using Assisted Installer and Small ISO.

- Requirements:

    - Podman.
    - Ansible.
        - Ansible modules: containers.podman and community.general
          You can install all the requirements with: `ansible-galaxy collection install -r requirements.yaml`

- Steps:

    1- git clone the ztp-cluster-deploy repo

    2- go to ai-deploy-cluster-singlenode dir

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
	- name: Deploy single node cluster with assisted installer
	  hosts: provisioner
	  environment:
	    PATH: "/usr/bin/:/usr/local/bin/:{{ ansible_env.PATH }}"
	  roles:
	    - role: prepare-environment
	      tags: prepare-environment
	      become: yes
	    - role: create-cluster
	      tags: create-cluster
	      become: yes
	    - role: add-baremetal-node
	      tags: add-baremetal-node
	      become: yes
	    - role: deploy-cluster
	      tags: deploy-cluster
	      become: yes

        Just specify the tag as we did in step 5

- After deployment:

    - In the installation node run the below commands to check the created clusters and nodes. You should see similar output.

            $ aicli list cluster

		+-------------+--------------------------------------+--------------+----------------------------+
		|   Cluster   |                  Id                  |    Status    |         Dns Domain         |
		+-------------+--------------------------------------+--------------+----------------------------+
		|   test-aut  | eaf6b793-d2b0-496d-827a-93abd8e041af |  installed   |      cluster.testing       |
		+-------------+--------------------------------------+--------------+----------------------------+

            $ aicli list hosts

		+----------------------------------------------+----------+--------------------------------------+-----------+--------+----------------+
		|                     Host                     | Cluster  |                  Id                  |   Status  |  Role  |       Ip       |
		+----------------------------------------------+----------+--------------------------------------+-----------+--------+----------------+
		| single-node-cluster.test-aut.cluster.testing | test-aut | 0471f8d5-812a-1e08-42e0-27e173750188 | installed | master | 192.168.112.34 |
		+----------------------------------------------+----------+--------------------------------------+-----------+--------+----------------+

    - You can download the kubeconfig of your cluster using the command below

            $ aicli download kubeconfig {YOUR_CLUSTER_NAME} --path ~/

    - Use the kubeconfig with OC command to check the openshift cluster nodes. You should have one node with master/worker roles

	# oc get nodes

	NAME                                           STATUS   ROLES           AGE   VERSION
	single-node-cluster.test-aut.cluster.testing   Ready    master,worker   22m   v1.20.0+d9c52cc

