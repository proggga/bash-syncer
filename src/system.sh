system:raise_error() {
    echo "Error: $1";
    press_any_key;
    exit 2;
}

system:press_any_key() {
    if [ "$(uname)" != "Linux" ] ; then
        read -n1 -r -p "Press space to continue..." press_any_key_variable
    fi;
}
