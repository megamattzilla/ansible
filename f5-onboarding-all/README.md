🚧 This project is under construction and is not yet ready for production use. 🚧

### Ansible playbook to onboard common configurations for VE, iSeries, and rSeries devices.

This playbook automates basic onboarding tasks for F5 BIG-IP and F5OS platforms, including VLANs, trunks, and interface settings.
It is intended to be modular, platform-aware, and beginner-friendly.

---

#### Outstanding TODO:
- **General**
    - Add Hardware model to inventory.
    - add optional description for each task in playbook (including interface description only)

- **VE (Virtual Edition)**
    - Placeholder for disk resize (used in cloud deployments)
    - All Declarative Onboarding (DO) reference tasks

- **iSeries**
    - Fix readme for skipping vlans in LAGs
    - check TMOS version and upgrade to gold image if needed
    - All Declarative Onboarding (DO) reference tasks

- **rSeries host**
- ✅ Done with all tasks currently scoped for rSeries host.
    - Deferred to manual for now: **Note:** must be manually configured before Ansible runs
        - [Upgrade to desired F5OS version](https://clouddocs.f5.com/products/orchestration/ansible/devel/f5os/modules_3_0/f5os_system_image_import_module.html#f5os-system-image-import-module-3)
        - [Configure Port groups status:](https://clouddocs.f5.com/api/rseries-api/F5OS-A-1.0.0-cli.html#r5r10-config-mode-commands-portgroups)
        - [License rSeries Steps](https://techdocs.f5.com/en-us/f5os-a-1-3-0/f5-rseries-systems-administration-configuration/title-rseries-system-overview.html)
            - F5OS module `f5os_license` can be used to automate license installation, but requires internet access on F5 hardware.
- **rSeries tenant**
    - All DO reference tasks


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
ansible-playbook -i inventory all.yaml -e "f5hosts=f5_demo_rSeries_A" --vault-password-file ~/.secrets/vault.secret

#Specific tasks:
ansible-playbook -i inventory all.yaml -e "f5hosts=f5_demo_rSeries_A" --vault-password-file ~/.secrets/vault.secret --tags vlan,interface
```

### Onboarding Stages to be performed by this codebase:

1. Before Ansible runs:
    - Hardware:
        - must be powered on and accessible via mgmt IP on TCP 22/443
        - admin/root password set
        - licensed
        - netHSM configured
        - rSeries:
            - running desired F5OS version
            - interface bundling configured (if needed)
    - VE:
        - deployed with desired TMOS version
        - accessible via mgmt IP on TCP 22/443
        - admin password set

1. Pre-System Onboarding:
    - rSeries only:
        - rSeries host system configuration
        - deploy TMOS tenant
        - set admin/root passwords

1. TMOS System Configuration:
    - User accounts
    - Hostname, MOTD, Login Banner
    - Networking (VLANs, trunks, interfaces)
    - Self-IP, Routes
    - DNS, NTP, LLDP
    - SNMP
    - HTTPD TLS settings and idle timeout
    - F5 module provisioning
    - DB variables for restjavad, extram etc...
    - HA (tentatively scoped)

1. LTM Configuration:
    - SNAT Pools
    - Data Groups
    - iRules
    - SSL Certificates and Keys
    - Virtual Servers

1. SSLO Configuration

Required vars:
```yaml
TBD
```


### Changelog:
- 7/25/25
    - Added idempotent admin and root default password reset for rSeries tenants.
    - Split rSeries role into host and tenant playbooks.
        - `host.yaml` now contains tasks for the rSeries host.
        - `tenant.yaml` contains tasks for the rSeries tenant.
    - Fixed issue where if the rSeries tenant variables are set to ansible_state=absent but running_state=deployed the f5os_tenant_wait task would run erroneously.
    - added rSeries tenant vlan shortcut:
        - Added `vlans: ALL` to tenant definition to use all vlans defined in `vlans` variable.
        - This allows the tenant to use all VLANs defined in the `vlans` variable without needing to specify each VLAN individually.
    - Added rSeries tenant as a child group of the rSeries host.
        - The tenant will likely share variables with the rSeries host, so it is defined as a child group for now.
    - documented pre-work before ansible runs for each platform type under "Onboarding Stages to be performed by this codebase" in README.md

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