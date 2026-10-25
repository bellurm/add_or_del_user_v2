#!/bin/bash

print_adduser_hint() {
    cat << 'EOF'

***** INFO *****
In the 'Full Name' field, you can enter anything (or leave blank).
The only important thing is the *username* you type first.
Press ENTER to skip unwanted fields.

EOF
}

add_user() {
    echo
    read -rp "New username: " newUser

    if [[ -z "$newUser" ]]; then
        echo "[-] Username cannot be empty."
        return 1
    fi

    if ! [[ "$newUser" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo "[-] Invalid username. Use lowercase letters, digits, '-' or '_'."
        echo "    Example: cyberworm, test_user, demo123"
        return 1
    fi

    if id "$newUser" &>/dev/null; then
        echo "[-] User '$newUser' already exists."
        return 1
    fi

    print_adduser_hint

    echo "[*] Creating user '$newUser'..."
    adduser "$newUser" || {
        echo "[-] adduser failed. Aborting."
        return 1
    }

    echo "[*] Adding '$newUser' to 'sudo' group..."
    usermod -aG sudo "$newUser" || {
        echo "[-] Failed to add '$newUser' to sudo group."
        return 1
    }

    echo
    echo "[+] User '$newUser' created and added to 'sudo' group."
    echo "[+] You can now login as '$newUser' and use 'sudo <command>'."
    echo
}

delete_user() {
    echo
    read -rp "Enter the username to delete: " username

    if [[ -z "$username" ]]; then
        echo "[-] Username cannot be empty."
        return 1
    fi

    if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo '[-] Invalid username.' >&2
        return 1
    fi
    if [[ "$username" == "root" ]]; then
        echo "[-] You cannot delete the 'root' user."
        return 1
    fi

    currentUser="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"
    if [[ -n "$currentUser" && "$username" == "$currentUser" ]]; then
        echo "[-] Refusing to delete the currently logged-in user ('$currentUser')."
        echo "    Log in as another user (or root) and try again if you really want this."
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        echo "[-] User '$username' does not exist."
        return 1
    fi

    echo
    read -rp "Really delete user '$username' and their home directory? [y/N]: " confirm
    case "$confirm" in
        y|Y)
            echo "[*] Deleting user '$username'..."
            if userdel -r -- "$username"; then
                echo "[+] User '$username' has been deleted."
            else
                echo "[-] Failed to delete '$username'." >&2
                return 1
            fi
            ;;
        *)
            echo "[*] Aborted. User '$username' was NOT deleted."
            ;;
    esac
}

if [[ "$(id -u)" -ne 0 ]]; then
    echo
    echo "[-] Please run this script as root."
    echo "    Example: sudo su  # then run the script"
    echo
    exit 1
fi

echo
echo "===== User Management Menu ====="
PS3="Choose an option (1-3): "

select option in "Add User" "Delete User" "Exit"; do
    case "$option" in
        "Add User")
            add_user
            exit $?
            ;;
        "Delete User")
            delete_user
            exit $?
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

echo
echo "Done."
echo
