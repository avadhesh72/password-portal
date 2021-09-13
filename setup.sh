#!/bin/bash

# Include all required vars
# Update include/setup-vars.sh based on your requirement
source include/setup-vars.sh

# DB related functions

# Generate DB input
db_input(){
	echo 
	echo "Provide input for database:"
	echo
	read -p "Continue [y/n]: " choice
	echo
	if [ "$choice" == "y" ] || [ "$choice" == "Y" ];then
		echo "db_name: $db_name" > $DB_VARS_FILE
		echo "db_table: $db_table" >> $DB_VARS_FILE
		echo "Setting up 'DB: $db_name' & 'DB Table: $db_table' in $DB_VARS_FILE"
		echo

		read -s -p "DB Root Password: " db_r_passwd
		ansible-vault encrypt_string -n db_root_pass $db_r_passwd \
			--vault-password-file $vault_pass_file >> $DB_VARS_FILE
		echo
		read -p "DB User Name: " db_username
		echo "db_user: $db_username" >> $DB_VARS_FILE
		echo
		read -s -p "DB User Password: " db_u_passwd
		ansible-vault encrypt_string -n db_pass $db_u_passwd \
			--vault-password-file $vault_pass_file >> $DB_VARS_FILE
		echo
	elif [ "$choice" == "n" ] || [ "$choice" == "N" ]; then
		echo "Cool. Exiting!" && exit 0
	else
		echo "Error! Wrong choice" && exit 1
	fi
}

# Setup DB server
db_setup(){
	echo
	echo "Connecting to DB Server as $db_host_user user"
	echo
	# Note: If $db_host_user user is not root and have valid sudo access, \
	#	add -K option in below command at the end."
	
	ansible-playbook -i inventory/hosts playbooks/db.yml -e ansible_user=$db_host_user \
		-k --vault-password-file $vault_pass_file
}


# Create additional user to manage root password
gen_pass_non_root(){
	read -s -p "Enter password for $user_to_create: " n_r_passowrd
	ansible-vault encrypt_string -n pass_key $n_r_passowrd \
		--vault-password-file $vault_pass_file > $non_root_pass_var_file
	echo
}

play_add_user(){
	echo
	echo "Connect to target machine as $existing_user user"
	echo
	# Note: If $existing user is not root and have valid sudo access, \
	#	add -K option in below command at the end."
	ansible-playbook -i inventory/hosts playbooks/passwd-mgmt.yml -e ansible_user=$existing_user \
		-e user_name=$user_to_create --tags=user-mgmt -k --vault-password-file $vault_pass_file 
}

# Root Password update functions
#gen_pass_root(){
#	read -s -p "Enter password for root: " r_passowrd
#	ansible-vault encrypt_string -n root_pass_key $r_passowrd \
#		--vault-password-file $vault_pass_file > $root_pass_var_file
#	echo
#}

play_root_pass_change(){
	echo
	echo "Connecting to target machine as $user_to_create user"
	echo $vault_pass_file
	echo
	ansible-playbook -i inventory/hosts playbooks/passwd-mgmt.yml -e ansible_user=$user_to_create \
		--tags=root-passwd-update -k --vault-password-file $vault_pass_file
}


usage(){
	
	echo
	echo
	echo "				----------------------------------			"
	echo " 				WELCOME TO ROOT PASSWORD MANAGEMENT			"
	echo "				-----------------------------------			"
 	echo 
	echo 	
	echo 
	echo " -d Generate database related information (DB name/table, user and password)"
	echo " -m Run Playbook to Setup Database"
	echo " -n Generate encrypted password for non-root user ($user_to_create)"
	echo " -a Run Ansible playbook to add user, which will manage root password"
	echo " -p Run Ansible playbook to change root password and update record in db"
	echo " -h print this help msg"
	echo
	exit 0
}

while getopts 'adhmnp' opt; do
	case $opt in
		a) play_add_user;;
		d) db_input;;
		h) usage;;
		m) db_setup;;
		n) gen_pass_non_root;;
		p) play_root_pass_change;;
		\?|*)	echo "Invalid Option: -$OPTARG" && usage;;
	esac
done
