#!/bin/sh
clear
oc whoami
[[ $? -gt 0 ]] && echo "💀 make sure you are logged in your Cluster with an cluster-admin user first! oc login..." && exit 1

echo
echo "creating admin and other 5 regular users..."
#switch to this if you wanna a random pwd for the admin user!
#readonly RANDOM_ADMIN_PWD=$(LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 13 ; echo)
readonly RANDOM_ADMIN_PWD=openshift
htpasswd -B -b -c ./htpasswd-users admin $RANDOM_ADMIN_PWD
htpasswd -B -b -c ./htpasswd-users admin openshift
htpasswd -B -b ./htpasswd-users user1 openshift
htpasswd -B -b ./htpasswd-users user2 openshift
htpasswd -B -b ./htpasswd-users user3 openshift
htpasswd -B -b ./htpasswd-users user4 openshift
htpasswd -B -b ./htpasswd-users user5 openshift

oc create secret generic htpasswd-secret --from-file=htpasswd=./htpasswd-users -n openshift-config
# oc replace -f ./oauth.yaml
oc apply -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd-secret
EOF

oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm groups new cluster-admins admin
rm -f ./htpasswd-users

echo
echo "in a couple of minutes you should be able to login with admin user using [admin/$RANDOM_ADMIN_PWD] credentials!"
echo
read -e -p "Do you want to remove the system 'kubeadmin' user? [Y/n]" typed_answer
typed_answer=${typed_answer:-y}
[[ $typed_answer == "y" ]] && echo "💀 deleting kubeadmin system user" && oc delete secret kubeadmin -n kube-system
