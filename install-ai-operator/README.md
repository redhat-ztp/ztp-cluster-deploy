# Assisted Installer operator (ipv6+disconnected) #
This is a set of playbooks to automate the deployment of Assisted Installer Operator
in a disconnected way, assuming ipv6 networking.

## Requirements ##

1. Podman.
2. Ansible.
3. Ansible modules `containers.podman` and `community.general`. You can install all the requirements with: 

  ```bash
  ansible-galaxy collection install -r requirements.yaml
  ```
        
## Steps ##

1. git clone the `ztp-cluster-deploy` repo
2. go to `install-ai-operator` dir
3. You need make a copy `inventory/hosts.sample` file and name it `hosts` under same directory.
4. Modify the [all:vars] section at `inventory/hosts` file based on your env.
5. If you want that the playbook creates the initial provisioner cluster for you, please run the
create-provisioner-cluster tag. It will generate a cluster, then you can copy the kubeconfig file
from /root/ocp/auth/kubeconfig installer vm into your local provisioner host. You can set that
on the inventory, for next steps.
6. Start the deployment with `prepare-environment` tag:

      ```console
      $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=prepare-environment
      ```

7. Create the OpenShift disconnected mirror if needed, by running the create-olm-mirror and
mirror-ai-images tags.

      ```console
      $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=offline-mirror-olm
      ```

8. Mirror Assisted Installer images. It will just use the default mirror settings, or it can also mirror
into an existing one, by providing the `provisioner_cluster_registry` var. It will also create a local
http server, where it will copy the RHCOS images. By default it will use the same VM used for the
disconnected registry, but you can provide your own using the `disconnected_http_server` var:

      ```console
      $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=mirror-ai-images
      ```
    
9. Finally install the Assisted Installer operator. You need to set the
`provisioner_cluster_kubeconfig` var in inventory:

      ```console
      $ sudo ansible-playbook playbook.yml -vvv -i inventory/hosts --tags=install-assisted-installer
      ```

10. Once deployed, you could create clusters using CRDs. This is going to be covered on a different section.
