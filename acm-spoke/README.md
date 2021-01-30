This playbook for spoke-clusters to join the ACM hub.

- Requirements:

    - We assume that there is already ACM hub up and running. If not you can use the ../acm-hub/playbook.yaml to create ACM hub.
        - Note: ACM hub shouldn't be created on one of the spoke-clusters.
    - The clusters that will be defiend in the inventroy/hosts under [clusters] section should have its profiles in the ztp-acm-manifest. Check the https://github.com/redhat-ztp/ztp-acm-manifests for more information

- Steps:

    1- git clone the ztp-cluster-deploy repo

    2- go to acm-spoke dir

    3- make a copy inventory/hosts.sample file and name it hosts under same directory.

    4- modify the [all:vars] section at inventory/hosts file to match your setup.

    5- Start the deployment.

        $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts
