
if [ ! $# == 1 ]; then
  echo "Usage: $0 10.4.0.183"
  exit
fi


ip=$1

ssh-keygen -R $ip
ssh -o "StrictHostKeyChecking no" root@$ip


