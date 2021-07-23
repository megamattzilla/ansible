# Easy F5 UCS backup via Ansible

## Demo!
![Alt Text](https://github.com/megamattzilla/ansible/raw/main/f5-ucs-backup/ucs-ansible.gif)

1.  [Requirements](#Requirements)
2.  [Ansible Setup](#Ansible_Setup)
3.  [Prepare Inventory](#Prepare_Inventory)
4.  [Prepare Ansible Vault](#Prepare_Ansible_Vault)  
    a.  [No Vault Option](#no_password_encrypt)  
    b.  [Vault Password File (optional)](#Vault_Password_File)
5.  [Run Ansible](#Run_Ansible)
6.  [Automatic Backups](#Automatic_Backups)
7.  [Coming Soon](#new_features)


# Requirements <a name="Requirements"></a>
- Have linux server with some disk space
- Linux server has access to Big-IP REST API (TCP/443)
- Linux server has internet access or access to software repositories

# Recommended Ansible Setup <a name="Ansible_Setup"></a>
- install python 3.8 (can sit along side current python version)
    - instructions: to install python 3.8 google your OS and `python3.8 install` should do the trick
- install python virtual environment
    - `python3.8 -m pip install --user virtualenv` 
- create python virtual environment
    - `python3.8 -m venv ~/python3.8-ansible` 
- activate python environment
    - `source ~/python3.8-ansible/bin/activate`
- update pip for good measure
    - `python -m pip install --upgrade pip`
- install latest ansible via pip (in virtual environment)
    - `python -m pip install ansible`

# Prepare inventory and var files <a name="Prepare_Inventory"></a>
- Edit inventory file with your Big-IP hostname(s) and management IP address information
- Edit group_vars/ucsBackupTargets.yaml file with your F5 username and UCS backup directory

# Prepare ansible vault <a name="Prepare_Ansible_Vault"></a>
*if you do not want to use ansible vault to encrypt the F5 admin password skip to "not encrypting admin password". [No Vault Option](#no_password_encrypt)

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

(optional) Create a vault password file so you do not need to provide vault password at ansible run time. <a name="Vault_Password_File"></a>
- Create directory to store the vault password file 
    - `mkdir ~/.secrets`
- Create vault password file
    - `echo "your vault password here" > ~/.secrets/vault.secret`
        - or `vi`/`nano`/`vim` to create the file
- When you run ansible-playbook you can reference this file by adding the argument `--vault-password-file ~/.secrets/vault.secret`

## Not encrypting admin password <a name="no_password_encrypt"></a>
Its recommended to use ansible vault to encrypt the Big-IP admin password value while its stored in-rest, however this is not required.  

Ansible vault does not encrypt secrets in-use or in-transit. It's worth noting ansible does not log the password by default and the F5 API is utilizing HTTPS to encrypt in-transit.  

If you want to skip ansible vault encryption, just replace the `password:` var in group_vars/ucsBackupTargets.yaml with your password.  
  
Example:
```
password: "supersecretpassword"
```
An easy alternative is to store the password in a bash/shell variable.  
`export BIGIP_PASSWORD="supersecretpassword"`  

Then configure the password var to use the bash variable:
```
password: "{{ lookup('env','BIGIP_PASSWORD') }}"
```
# Run the playbook <a name="Run_Ansible"></a>
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
# Schedule ansible to run UCS backups automatically <a name="Automatic_Backups"></a>
The simplest way to run ansible at an interval would be to schedule a cron-job.  

Alternatives would be to run an ansible workflow management software like AWX, Ansible Tower, or [Concord](https://concord.walmartlabs.com/docs/plugins/ansible.html).  

Let's create a simple cron-job to run our ansible task at an interval   
```bash
* * * * * /usr/bin/env bash -c 'cd /home/user/github/ansible/f5-ucs-backup && source /home/user/python3.8-ansible/bin/activate && ansible-playbook -i inventory ucs-backup.yaml --vault-password-file /home/user/.secrets/vault.secret' >> /home/user/github/ansible/f5-ucs-backup/ansible.log 2>&1
```
*substitute your username and path as needed  
*if you are using vault, you need to setup a password file to open the vault without user interaction. See [Vault Password File](#Vault_Password_File)  
*all ansible output logged to ansible.log to review later if needed  

## Coming Soon! <a name="new_features"></a>
- Delete UCS after x days option #DONE!
- SCP UCS to storage server option
- What else? Feedback welcome!