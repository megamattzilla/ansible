🚧 This project is under construction and is not yet ready for production use. 🚧

### Ansible playbook to onboard common configurations for VE, iSeries, and rSeries devices.

This playbook automates basic onboarding tasks for F5 BIG-IP and F5OS platforms, including VLANs, trunks, and interface settings.
It is intended to be modular, platform-aware, and beginner-friendly.

---

#### Outstanding TODO:
- **General**
    - Add Hardware model to inventory.
    - document pre-work before ansible runs for each platform type
    - add optional description for each task in playbook (including interface description only)

- **VE (Virtual Edition)**
    - Placeholder for disk resize (used in cloud deployments)
    - All Declarative Onboarding (DO) reference tasks

- **iSeries**
    - Fix readme for skipping vlans in LAGs
    - check TMOS version and upgrade to gold image if needed
    - All Declarative Onboarding (DO) reference tasks

- **rSeries**

    - fix tenant upload failed when
    - Skip vlans on interfaces if none defined.
    - Configure admin password on fresh tenant
    - DNS/NTP at F5OS level
    - All vlans for tenant shortcut
    - Check F5os version and upgrade to gold image if needed [Docs link](https://clouddocs.f5.com/products/orchestration/ansible/devel/f5os/modules_3_0/f5os_system_image_import_module.html#f5os-system-image-import-module-3)
    - All DO reference tasks
    - Deferred to manual: **Note:** must be manually configured before Ansible runs
        - [Configure Port groups:](https://clouddocs.f5.com/api/rseries-api/F5OS-A-1.0.0-cli.html#r5r10-config-mode-commands-portgroups)
        - [License rSeries Steps](https://techdocs.f5.com/en-us/f5os-a-1-3-0/f5-rseries-systems-administration-configuration/title-rseries-system-overview.html)
            - F5OS module `f5os_license` can be used to automate license installation, but requires internet access on F5 hardware.



---

### Overview

This playbook uses a combination of modules from two F5 Ansible collections: `f5_modules` (BIG-IP) and `f5os` (F5OS/rSeries).
It selects which role and modules to use based on the `platform_type` variable defined per host.

#### Modules Used

| Module | Purpose |
| :------ | :------ |
| `f5networks.f5_modules.bigip_interface` | Configure interface bundling or breakout ports on iSeries |
| `f5networks.f5_modules.bigip_trunk`     | Create trunk (LACP group) on iSeries |
| `f5networks.f5_modules.bigip_vlan`      | Create VLANs on iSeries or VE |
| `f5networks.f5os.f5os_vlan`             | Create VLANs on rSeries |
| `f5networks.f5os.f5os_trunk`            | Create trunk interface (LAG) on rSeries |
| `f5networks.f5os.f5os_interface`        | Assign VLANs to interfaces on rSeries |

> 💡 **Tip for beginners:**
> BIG-IP uses classic TMSH/REST APIs, while rSeries (F5OS) is built on a new RESTCONF-style API. These require different modules.

#### REST API Endpoints Used

| API Endpoint | Purpose |
| :------ | :------ |


> Full documentation on F5 modules can be found here:
> - [BIG-IP Ansible modules](https://clouddocs.f5.com/products/orchestration/ansible/devel/f5_modules/F5modules-index.html)
> - [F5OS modules](https://clouddocs.f5.com/products/orchestration/ansible/devel/f5os/F5OS-index.html)

---

### Setup
Tested with:
- Ansible 2.18.6 python_version 3.13.5
- f5networks.f5os 1.18.0
- f5networks.f5_modules 1.36.0
- paramiko 3.5.1

Install F5 modules:
```bash
ansible-galaxy collection install f5networks.f5_modules
ansible-galaxy collection install f5networks.f5os #requires paramiko
pip install paramiko
```
If using SSH password, Install module `sshpass`:
Installation varies per ansible host OS. Google `install sshpass {{ your operating system }}`

### Run the Playbook
```bash
#All tasks
ansible-playbook -i inventory_scratch all.yaml -e "f5hosts=f5_demo_rSeries" --vault-password-file ~/.secrets/vault.secret

#Specific tasks:
ansible-playbook -i inventory_scratch all.yaml -e "f5hosts=f5_demo_rSeries" --vault-password-file ~/.secrets/vault.secret --tags vlan,interface
```


Required vars:
```yaml
TBD
```


### Changelog:
- 7/14/25
    - added loading f5secrets.yaml to manage secrets encrypted with ansible-vault
    - rSeries:
        - added ability to delete rSeries tenant (state: absent)
        - added SNMP, DNS, NTP, LLDP configuration tasks
        - added tags to all tasks
- 6/25/25
    - updated dependency_check.yaml with all non-standard modules used in this playbook
    - fixed some broken documentation links (Thanks Mike!)
    - added ansible testing version info to README
    - rSeries LAG improvements:
        - renamed trunks to lags to match rSeries terminology
        - Add variable for LACP type
        - omit LAG attributes for type lacp if LAG is set to static.
        - omit native vlan if not set
        - skip configuring LAG if none defined.
    - rSeries interface improvements:
        - skip configuring interfaces if none defined.
- 4/17/25
    - rSeries: added Create tenant (F5OS rSeries uses tenants to host BIG-IP instances) task
        - Added wait for tenant deployment to make sure tenant is running before moving on
- 4/02/25
    - moved iSeries tasks to single role
    - moved platform_type to host variable
    - assign vlans to lags and interfaces
    - rSeries:
        - upload tenant image
- 3/19/25 Initial Version.