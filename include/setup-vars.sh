db_host_user=root
existing_user=root # To connect host in user-mgmt playbook
user_to_create="user3" # User to be created in user-mgmt.yml and this user will change password of root in passwd-mgmt.yml
vault_pass_file="~/.ssh/a-vault-pass" # must change with your own vault pass file
non_root_pass_var_file="playbooks/vars/non-root-pass.yml"
root_pass_var_file="playbooks/vars/root-pass.yml"
DB_VARS_FILE="playbooks/vars/db.yml"
db_name=passwd_mgmt_data
db_table=passwd_mgmt_table

