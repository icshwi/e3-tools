

user_name=${USER}
host_name=${HOSTNAME}

ssh-keygen -t rsa -b 4096 -C "${user_name}@${host_name}"

echo ""
echo " ---- snip snip ---"
echo ""
cat ${HOME}/.ssh/id_rsa.pub
echo ""
echo " ---- snip snip ---"
echo ""
