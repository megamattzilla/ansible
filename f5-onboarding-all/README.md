### Ansible playbook to onboard common configurations for VE, iSeries, and rSeries devices.

This playbook automates basic onboarding tasks for F5 BIG-IP and F5OS platforms, including VLANs, trunks, and interface settings.  
It is intended to be modular, platform-aware, and beginner-friendly.

---

### Coming Soon

- **VE (Virtual Edition)**
    - Placeholder for disk resize (used in cloud deployments)
    - All Declarative Onboarding (DO) reference tasks

- **iSeries**
    - All Declarative Onboarding (DO) reference tasks

- **rSeries**
    - Port groups: [F5 rSeries CLI guide (F5OS-A)](https://clouddocs.f5.com/api/rseries-api/F5OS-A-1.0.0-cli.html#r5r10-config-mode-commands-portgroups)
        - **Note:** Port groups must be manually configured before Ansible can assign interfaces
    - All DO reference tasks
    - License rSeries host? *(To be confirmed — may be manual step after physically installing and configuring management IP)*

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
> - [BIG-IP Ansible modules](https://clouddocs.f5.com/products/orchestration/ansible/latest/)
> - [F5OS modules](https://clouddocs.f5.com/ansible/f5os/)

---

### Setup
Install F5 modules:
```bash
ansible-galaxy collection install f5networks.f5_modules
ansible-galaxy collection install f5networks.f5os #requires paramiko 
pip install paramiko 
```
If using SSH password, Install module `sshpass`:  
Installation varies per ansible host OS. Google `install sshpass {{ your operating system }}`



Required vars:
```yaml
TBD
```


### Changelog: 
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