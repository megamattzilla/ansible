### Ansible playbook to onboard common configurations for VE, iSeries, and rSeries devices.

### Coming Soon
- VE
    - placeholder for disk resize
    - all DO reference tasks 
- iSeries
    - all DO reference tasks
- rSeries
    - port groups https://clouddocs.f5.com/api/rseries-api/F5OS-A-1.0.0-cli.html#r5r10-config-mode-commands-portgroups
    - all DO reference tasks   

    - create tenant
    - license rSeries host? 


### Overview 

The playbook uses these Ansible Modules:
| Module | Purpose 
| :------ | :------ | 
|f5networks.f5_modules.bigip_interface | Configure interface bundle on iSeries |
|f5networks.f5_modules.bigip_trunk | Configure trunk interface on iSeries |
|f5networks.f5_modules.bigip_vlan | Configure vlan on iSeries or VE |
|f5networks.f5os.f5os_vlan | Configure vlan on rSeries |
|f5networks.f5os.f5os_trunk | Configure trunk interface (LAG) on rSeries  |

The playbook uses these REST API endpoints:
| API Endpoint | Purpose 
| :------ | :------ | 


### Setup
Install F5 modules:
```bash
ansible-galaxy collection install f5networks.f5_modules
ansible-galaxy collection install f5networks.f5os
```
If using SSH password, Install module `sshpass`:
Installation varies per ansible host OS. Google `install sshpass {{ your operating system }}`


Required vars:
```yaml
TBD
```


### Changelog: 
- 4/02/25
    - moved iSeries tasks to single role
    - moved platform_type to host variable
    - assign vlans to lags and interfaces
    - rSeries:
        - upload tenant image
- 3/19/25 Initial Version. 


