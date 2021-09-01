#!/bin/bash

target_user=user1

[ id $target_user > /dev/null 2>&1 ] && echo "Warning! $target_user already exists." && exit 1

[ -d /home/$target_user ] && echo "Error! /home/$target_user already exists" && exit 1

[ -f /etc/sudoers.d/$target_user ] && echo "Error! /etc/sudoers.d/$target_user already exists" && exit 1

for i in {990..999};do
  id $i > /dev/null 2>&1
  if [ $? != 0 ];then
    useradd -u $i $target_user
    id $i > /dev/null 2>&1 &&   echo "Successfully created user $target_user"
    # Setup sudo
    echo "%$target_user        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/$target_user
    check_sudo=$(sudo -l -U $target_user)
    if echo $check_sudo|egrep "$target_user is not allowed";then
      echo "sudo access to $target_user failed" && exit 1
    else
      echo "sudo access successfully configured for $target_user" && exit 0
    fi
    break;
  fi
done
