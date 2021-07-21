# Easy and Simple F5 UCS backup via Ansible

# Requirements
- Have linux server with some disk space
- Linux server has access to Big-IP REST API (TCP/443)
- Linux server has internet access or access to software repos

# Recommended Ansible Setup
- install python 3.8 (can sit along side current python version)
    - instructions: to install python 3.8 google your OS and `python3.8 install` should do the trick
- install python virtual enviroment
    - `python3.8 -m pip install --user virtualenv` 
- create python virtual enviroment
    - `python3.8 -m venv ~/python3.8-ansible` 
- activate python enviroment
    - `source ~/python3.8-ansible/bin/activate`
- update pip for good measure
    - `python -m pip install --upgrade pip`
- install latest ansible via pip (in virtual enviroment)
    - `python -m pip install ansible`

# Prepare inventory and var files 
- Edit inventory file with your Big-IP hostnames and management IP address information
- Edit group_vars/ucsBackupTargets.yaml file with your F5 username and UCS backup directory

# Prepare ansible vault
- Create encrypted F5 password by invoking ansible vault  
`ansible-vault encrypt_string`  
        - You will be prompted to create a new vault password. This is the password you will specify at ansible runtime to decrypt the stored F5 password.  
        - Next, you will be prompted for a string to encrypt. Just enter the F5 password value and then CTL-d.  
        - Take the vault output and replace the value in group_vars/ucsBackupTargets.yaml password: <value>  
Example
``` 
ansible-vault encrypt_string
New Vault password: 
Confirm New Vault password: 
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
supersecretpassword
```
The resulting output will be:  
``` 
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          38396431323537376335326636323533353561333232343937353837386666353764346264643539
          3939396464336630386163343862623937326561666463640a356134396238346237306235316338
          35643031613762306336613266353239653530326331613838646331393833613731646539626331
          6631333139323236630a353532643638343566306265333939643036313137623230626633326131
          31623262363565653164393363316362393562353730313139613935333562313938
Encryption successful
```
Copy the output and replace value in the group_vars/ucsBackupTargets.yaml file:
```
password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          38396431323537376335326636323533353561333232343937353837386666353764346264643539
          3939396464336630386163343862623937326561666463640a356134396238346237306235316338
          35643031613762306336613266353239653530326331613838646331393833613731646539626331
          6631333139323236630a353532643638343566306265333939643036313137623230626633326131
          31623262363565653164393363316362393562353730313139613935333562313938
```

# Run the playbook
`ansible-playbook -i inventory ucs-backup.yaml --ask-vault-pass`   
Expected output:  
```
Vault password: 

PLAY [Backup UCS File] ***************************************************************************

TASK [Create UCS backup directory if it does not exist] ******************************************
ok: [bigip01.example.local]

TASK [Download a new UCS] ************************************************************************
changed: [bigip01.example.local -> localhost]

PLAY RECAP ***************************************************************************************
bigip01.example.local   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```