#!/bin/bash

function warning() {
    warning="\n\n*****WARNING*****\nYou have to enter the username you just entered in the 'Full Name []:' field.\n
    You can leave the remaining fields blank.\n
    Transactions will start within 45 seconds.\n"
    
    warnReboot="\n\n*****WARNING*****\nOnce the processes are complete, you have to reboot your device.\n
    To log in again, you will need the new username and password you entered in the application.\n"
    
    echo -e $warning
    echo -e $warnReboot
}

function add_user() {
    read -p "New user: " newUser
    
    echo -e >> /etc/sudoers "$newUser    ALL=(ALL:ALL) ALL"
    echo -e "Done.\n"
    
    warning
    
    sleep 20
    
    sudo adduser $newUser
    
    echo -e "\nYou should reboot your machine with 'reboot' command."
}

function delete_user() {
    read -p "Enter the username to delete: " username

    if id "$username" &>/dev/null; then
        userdel -r "$username"
        echo "User $username has been deleted along with their home directory."
    else
        echo "User $username does not exist."
    fi
}

if [ "$(whoami)" != "root" ]; then
    echo -e "Please, you have to be 'root' with 'sudo su' command.\n"
    echo -e "Don't worry. We will give to your user a 'root' permission. We can't do this without 'root'.\n"
    exit 1
fi

echo "Do you want to add or delete a user?"
select option in "Add User" "Delete User" "Exit"; do
    case $option in
        "Add User")
            add_user
            break
            ;;
        "Delete User")
            delete_user
            break
            ;;
        "Exit")
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1, 2, or 3."
            ;;
    esac
done
