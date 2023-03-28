# Openshift Gitops Cluster Bootstrap

This project contains a set of ArgoCD manifests used to bootstrap a Openshift Cluster v4.x intended for Developer workflows demo.

It uses the ArgoCD App of Apps pattern to pre-install and configure a set of Openshift Operators to support Developer Workflows.

# Openshift GitOps installation
You can choose to install **Openshift GitOps** Operator manually from the Operator Hub in the Openshift Console (Administrator Perspective) or you can

 1. Authenticate as a `cluster-admin` on your cluster
```
oc apply -f ./openshift-gitops-install/operator.yaml
oc apply -f ./openshift-gitops-install/argocd.yaml
```

 2. Apply additional `ClusterRoleBindings` to ArgoCD Controller Service Accounts
```
oc apply -f ./openshift-gitops-install/rbac.yaml
```

 3. **IMPORTANT**: Make your cluster admin(s) ArgoCD Admins
```
oc adm groups new cluster-admins <your admin username here>
```

## Openshift DevSpaces configs

```
oc create namespace openshift-devspaces
oc create secret generic github-oauth-config --from-literal=id=${devspaces_github_client_id} --from-literal=secret=${devspaces_github_client_secret} -n openshift-devspaces
oc label secret github-oauth-config -n openshift-devspaces --overwrite=true app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=oauth-scm-configuration
oc annotate secret github-oauth-config -n openshift-devspaces --overwrite=true che.eclipse.org/oauth-scm-server=github
oc create secret generic ocp-github-app-credentials -n openshift-config --from-literal=client_id=${ocp_github_client_id} --from-literal=clientSecret=${ocp_github_client_secret}
```