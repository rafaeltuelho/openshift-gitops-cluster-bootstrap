#!/bin/sh
clear

readonly SCRIPT_RELATIVE_DIR_PATH=$(dirname -- "${BASH_SOURCE}")
#echo " This script is located at: $( dirname -- "${BASH_SOURCE}" ) "
#echo " This script is located at: $( dirname -- "$(readlink -f "${BASH_SOURCE}")" ) "

oc whoami
[[ $? -gt 0 ]] && echo "💀 make sure you are logged in your Cluster with an cluster-admin user first! oc login..." && exit 1

echo
echo "Install Openshift Gitops (ArgoCD) Operator"
oc apply -f $SCRIPT_RELATIVE_DIR_PATH/../openshift-gitops-install/operator.yaml

echo
echo "wait (30s) until the Gitops operators is ready..."
sleep 30
oc wait pods -n openshift-operators -l control-plane=controller-manager --for condition=Ready

echo
echo "now create an argocd instance"
oc create -f $SCRIPT_RELATIVE_DIR_PATH/../openshift-gitops-install/argocd.yaml

echo
echo "wait (5s) until the ArgoCD instance is ready..."
sleep 5

echo
echo "apply additional ClusterRoleBindings to ArgoCD Controller Service Accounts"
oc apply -f $SCRIPT_RELATIVE_DIR_PATH/../openshift-gitops-install/rbac.yaml

echo
echo "bootstrapping the components though Openshift GitOps (ArgoCD)..."
oc apply -f $SCRIPT_RELATIVE_DIR_PATH/../root-app/app-of-apps.yaml

argocdurl=$(oc get route openshift-gitops-server --ignore-not-found=true -n "openshift-gitops" -o jsonpath="{'https://'}{.status.ingress[0].host}")
echo
echo "you can now access Openshift Gitops though: $argocdurl"