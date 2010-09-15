source ~/.bashrc

pidof dropboxd &> /dev/null || dropbox start

keychain /home/jzacsh/.ssh/add/*.add
source ~/.keychain/$HOSTNAME-sh
