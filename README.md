# Root User Password Management

Change root password on demand using an with sudo permission, and store password history in mysql db.
And retrive root password from database on demand.

#### Pre-requisite
1. Packages:
    - Ansible 2.9

2. Update `inventory/hosts`

3. Install Ansible mysql collection
```bash
ansible-galaxy collection install community.mysql
```

4. Update following variables in include/setup-vars.sh as per the need or leave default
	- db_host_user
    - existing_user # To connect host in user-mgmt playbook
    - user_to_create # User to be created with sudo access and change root password on demand
    - vault_pass_file # must change with your own vault pass file


##### Imp Note 
1. `setup.sh -a` requirements:
Currently `setup.sh -a` will ask for target user's password to establish ssh for ansible (-k option).
If you want to use ssh keys, remove -k and provide ssh key in ansible-playbook command,
example: '--private-key key_full_path'

If `$existing_user` is not root and have valid sudo access, add -K option in below command at the end,
-K will ask additional sudo password to perform operation on target machine


#### Installation

1. Create an ansible vault password file
```bash
echo "mypass" > ~/.ssh/a-vault-pass
```
   
2. Run below command and understand `setup.sh` functionality
```bash
./setup.sh -h
```

3. Generate DB related information `playbooks/vars/db.yml`
```bash
./setup.sh -d
```

4. Setup DB server
```bash
./setup.sh -m
```

5. Generate password `playbooks/vars/non-root-pass.yml` for non-root user `$user_to_create`.
```bash
./setup.sh -n
```

6. Run ansible playbook to create `$user_to_create` on target machines
```bash
./setup.sh -a
```

7. Run Ansible playbook to change root password on target machine
```bash
./setup.sh -p
```
