to install clash and config as transparnt proxy into the VYOS box, run following command in the vm:

`sudo su`
`bash -c "$(cat /tmp/install.sh)"  && source /etc/profile &> /dev/null`

#or

`mkdir ~/.local/share -p`
`bash -c "$(cat /tmp/install.sh)"  && source /etc/profile &> /dev/null`
`source ~/.bashrc`

`bash /tmp/finalConfig.sh`