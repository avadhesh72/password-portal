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


# Password Management Portal

Django Web UI to retrive system password from centralized database. 

#### Pre-requisite
1. Python 3.6 or higher

2. Dababase must be accessible from remote network, example:
```
mysql> GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'%' IDENTIFIED BY 'db_pass' WITH GRANT OPTION;
mysql> FLUSH PRIVILEGES;
```

3. If application is needs to be run as non-root user, setup python venv and install required pip packages in virtual env

## Application deployment

1. Copy `PASSWD_PORTAL` dir to desired path

2. Run `PASSWD_PORTAL/rpm-pkgs.sh` to install required devel packages

3. Install pip modules
```bash
pip install -r requirements.txt
```

4. Update Database connection settings in `PASSWD_PORTAL/PASSWD_PORTAL/settings.py`
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'passwd_mgmt_data',
        'USER': 'dbuser',
        'PASSWORD': 'dbpass',
        'HOST': '192.168.122.48',
        'PORT': '3306',
    }
}
```

5. Generate models.py 
```bash
python manage.py inspectdb > models.py
```

6. Copy models.py to `PASSWD_PORTAL/PASSWD_PORTAL/passwdui/models.py` and add return string in model
```python
def __str__(self):
        return self.host_name
```

7. Add Application server IP in `PASSWD_PORTAL/PASSWD_PORTAL/settings.py`, example:
```
ALLOWED_HOSTS = ['192.168.43.250']
```

8. For new database do migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

9. Start app
```bash
python manage.py runserver 0.0.0.0:8000
```

### Additional steps to setup authentication

10. Create super user
```bash
python manage.py createsuperuser
```

11. Migrate auth changes to db
```bash
python manage.py migrate
```

12. Login to admin portal with super user and create user to authenticate app
- http://<App_Host_IP>:8000/admin

13. Access UI to retrive password and authenticate with user created in step 13
- http://<App_host_ip>:8000

14. Integrate of Django with oAuth2
``bash
- Go to Password-port folder

pip3 install django-oauth-toolkit

Edit settings.py and add 

INSTALLED_APPS = (
    ...
    'oauth2_provider',
)
	
from django.urls import include, path
from django.urls import include, re_path

urlpatterns = [
    ...
    path('o/', include('oauth2_provider.urls', namespace='oauth2_provider')),
	re_path(r'^o/', include('oauth2_provider.urls', namespace='oauth2_provider')),
]

$ python3 manage.py migrate oauth2_provider

RUN nohup python3 manage.py runserver 0.0.0.0:8080 &
```





