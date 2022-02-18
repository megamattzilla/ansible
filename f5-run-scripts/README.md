# Easy run F5 scripts via Ansible!

1.  [Requirements](#Requirements)
2.  [Ansible Setup](#Ansible_Setup)
3.  [Prepare Inventory](#Prepare_Inventory)
4.  [Prepare Ansible Vault](#Prepare_Ansible_Vault)  
    a.  [No Vault Option](#no_password_encrypt)  
    b.  [Vault Password File (optional)](#Vault_Password_File)
5.  [Run Ansible](#Run_Ansible)


# Requirements <a name="Requirements"></a>
- Have linux server with some disk space
- Linux server has access to Big-IP SSH (TCP/22)
- Linux server has internet access or access to software repositories

# Recommended Ansible Setup <a name="Ansible_Setup"></a>
- install python 3.8+ (can sit along side current python version)
    - instructions: to install python 3.8 google your OS and `python3.8 install` should do the trick
- install sshpass (if using SSH password authentication for Big-IPs)
    - instructions: for debian `sudo apt-get install sshpass` or google for your OS to install sshpass
- install python virtual environment
    - ```python3.8 -m pip install --user virtualenv```
- create python virtual environment
    - ```python3.8 -m venv ~/python3.8-ansible``` 
- activate python environment (you will need to run this the next time you login)
    - ```source ~/python3.8-ansible/bin/activate```
- update pip for good measure
    - ```python -m pip install --upgrade pip```
- install latest ansible via pip (in virtual environment)
    - ```python -m pip install ansible```

# Prepare inventory and var files <a name="Prepare_Inventory"></a>
- Clone this git repo to your linux machine
    - `git clone git@github.com:megamattzilla/ansible.git` 
- Edit inventory file with your Big-IP hostname(s) and management IP address information 
- Edit group_vars/f5.yaml file with your F5 username and password (recommended to use ansible vault to encrypt password)
*Pro-tip: Use [vscode SSH extension](https://code.visualstudio.com/learn/develop-cloud/ssh-lab-machines) to SSH and edit files on your remote linux machine 
# Prepare ansible vault <a name="Prepare_Ansible_Vault"></a>
*if you do not want to use ansible vault to encrypt the F5 admin password skip to "not encrypting admin password". [No Vault Option](#no_password_encrypt)

- Create encrypted F5 password by invoking ansible vault  
```ansible-vault encrypt_string```  
        - You will be prompted to create a new vault password. This is the password you will specify at ansible runtime to decrypt the stored F5 password.  
        - Next, you will be prompted for a string to encrypt. Just enter the F5 password value and then CTL-d.  
        - Take the vault output and replace the value in group_vars/f5.yaml ansible_ssh_pass: <value>  
  
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
Copy the output and replace value in the group_vars/f5.yaml file:
```
ansible_ssh_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          38396431323537376335326636323533353561333232343937353837386666353764346264643539
          3939396464336630386163343862623937326561666463640a356134396238346237306235316338
          35643031613762306336613266353239653530326331613838646331393833613731646539626331
          6631333139323236630a353532643638343566306265333939643036313137623230626633326131
          31623262363565653164393363316362393562353730313139613935333562313938
```

(optional) Create a vault password file so you do not need to provide vault password at ansible run time. <a name="Vault_Password_File"></a>
- Create directory to store the vault password file 
    - ```mkdir ~/.secrets```
- Create vault password file
    - ```echo "your vault password here" > ~/.secrets/vault.secret```
        - or `vi`/`nano`/`vim` to create the file
- When you run ansible-playbook you can reference this file by adding the argument ```--vault-password-file ~/.secrets/vault.secret```

## Not encrypting F5 password <a name="no_password_encrypt"></a>
Its recommended to use ansible vault to encrypt the Big-IP admin password value while its stored in-rest, however this is not required.  

Ansible vault does not encrypt secrets in-use or in-transit. It's worth noting ansible does not log the password by default and the ansible module is utilizing SSH to encrypt in-transit.  

If you want to skip ansible vault encryption, just replace the `ansible_ssh_pass:` var in group_vars/f5.yaml with your password.  
  
Example:
```
ansible_ssh_pass: "supersecretpassword"
```
An easy alternative is to store the password in a bash/shell variable.  
```export BIGIP_PASSWORD="supersecretpassword"```  

Then configure the password var to use the bash variable:
```
ansible_ssh_pass: "{{ lookup('env','BIGIP_PASSWORD') }}"
```
# Run the playbook <a name="Run_Ansible"></a>
```ansible-playbook f5-run-script.yaml -i inventory --ask-vault-pass```  
Expected output:  
```
Vault password: 

PLAY [Run F5 Scripts] *********************************************************************************************************************************************************************************

TASK [Run Cert-mapping Script] ************************************************************************************************************************************************************************
changed: [bigip02.example.local]

TASK [debug] ******************************************************************************************************************************************************************************************
ok: [bigip02.example.local] => {
    "msg": [
        "Virtual:          Profile:        Certificate:          Ciphers:",
        "__________________________________________________________",
        "/Common/auth2.0_captive_portal ssloprxy.f5kc.lab.local ssloprxy.f5kc.lab.local2 DEFAULT",
        "/Common/sslo_kerberos_prod.app/sslo_kerberos_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "/Common/sslo_noauth_prod.app/sslo_noauth_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "/Common/sslo_ntlm_prod.app/sslo_ntlm_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "Virtual server count: 4"
    ]
}

TASK [debug] ******************************************************************************************************************************************************************************************
ok: [bigip02.example.local] => {
    "msg": [
        "Virtual:          Profile:        Certificate:          Ciphers:",
        "__________________________________________________________",
        "/Common/auth2.0_captive_portal ssloprxy.f5kc.lab.local ssloprxy.f5kc.lab.local2 DEFAULT",
        "/Common/sslo_kerberos_prod.app/sslo_kerberos_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "/Common/sslo_noauth_prod.app/sslo_noauth_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "/Common/sslo_ntlm_prod.app/sslo_ntlm_prod-in-t-4 ssloT_prod_sslo.app/ssloT_prod_sslo-cssl-vhf default.crt",
        "f5kc.lab.local_CA DEFAULT",
        "Virtual server count: 4"
    ]
}

TASK [copy] *******************************************************************************************************************************************************************************************
changed: [bigip02.example.local -> localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************
bigip02.example.local      : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```
### The script output for each Big-IP is also written to a file in outputs folder indicated wit Big-IP name and date. The output is in .json format and can be later converted into yaml/xml/csv if needed.   
