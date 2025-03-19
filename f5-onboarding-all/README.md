### Ansible playbook to onboard common configurations for VE, iSeries, and rSeries devices.

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

Required vars:
```yaml
TBD
```


### Changelog: 
- 3/19/25 Initial Version. 


