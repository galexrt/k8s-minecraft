#!/bin/bash

# Unset the list as we rely on the plugin list file to change
export PLUGINS_TO_INSTALL=""
unset PLUGINS_TO_INSTALL

inotifywait \
    --event modify \
    --event attrib \
    --event close_write \
    --event close_nowrite \
    --event close \
    --event move_self \
    --monitor \
    /data/.plugins_install_list.txt | \
while read -r filename; do
    # TODO Future "debounce" by killing the background job
    #jobs -p | xargs kill -9
    wait
    (
        sleep 3
        echo "$(date) Plugins install list (${filename}) has been updated. Triggering plugin installation scripts ..."
        echo "Removing Jars before plugin install ..."
        /custom_scripts/pre/jars-removal.sh
        echo "Installing plugins from list ..."
        /custom_scripts/pre/plugins-install.sh
        echo "$(date) Plugins install from list completed."
    ) &
done
