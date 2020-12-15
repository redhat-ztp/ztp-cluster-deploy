This is a set of playbooks to automate deployment of Openshift cluster and remote worker node, using Assisted Installer
and Small ISO.

Requirements:

- Podman
- Ansibale
    - Ansibale modules: community.libvirt, containers.podman and containers.general

Steps:
    1- git clone the ztp-cluster-deploy repo

    2- go to ai-deploly-cluster-remoteworker dir

    3- You need make a copy inventory/hosts.sample file and name it hosts under same directory.

    4- Modify the [all:vars] section at inventory/hosts file based on your HW env.

    5- Start the deployment with prepare-environment tag
        $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=prepare-envitronment

    6- Make sure that AI pod has been created and the http server is running 
        $ sudo systemctl status httpd
          httpd.service - The Apache HTTP Server
            Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
            Active: active (running) since Mon 2020-12-14 14:21:12 EST; 5h 55min ago
        $ sudo podman ps
         CONTAINER ID  IMAGE                                          COMMAND               CREATED      STATUS          PORTS                   NAMES
         2a9f6e4056a8  k8s.gcr.io/pause:3.2                                                 6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  2ae5adf6da27-infra
         603d56566a6b  quay.io/ocpmetal/postgresql-12-centos7:latest  run-postgresql        6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  db
         a4d2a578fe32  quay.io/ocpmetal/assisted-service:latest       /assisted-service     6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  installer
         f8ab3586816f  quay.io/ocpmetal/ocp-metal-ui:latest           /opt/bitnami/scri...  6 hours ago  Up 6 hours ago  0.0.0.0:5432->5432/tcp  ui
    Note: Disable firewalld in order to avoid any tcp ports blocking issues

    7- Based on your env and your machine intf us nmcli command to set the network-config under /opt/ dir
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

    8- Finally you can execute the rest of installation steps as 
        $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --skip-tags=prepare-envitronment
    Note: For any errors appear you can still run each installation step by its tag name
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


