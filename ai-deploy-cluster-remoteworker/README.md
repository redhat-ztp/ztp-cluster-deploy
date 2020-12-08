This is a set of playbooks to automate deployment of Openshift cluster and remote worker node, using Assisted Installer
and Small ISO.

Requirements:

- Podman
- Ansibale
    - Ansibale modules: community.libvirt, containers.podman and containers.general

The playbook needs to be executed in the BM node and config variables are in inventory/hosts.

