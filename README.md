### Setup all the required tools
* install asdf https://asdf-vm.com/#/core-manage-asdf-vm
* add asdf plugins https://asdf-vm.com/#/plugins-all
    ```
    asdf plugin-add terraform
    asdf plugin-add terragrunt
    asdf plugin-add kubectl
    asdf plugin-add helm
    asdf plugin-add eksctl
    ```

* run `asdf install` from root of the repository

### Setup VPC
* set AWS_PROFILE environment variable
    ```
    cd terraform/live/dev/vpc
    terragrunt init
    terragrunt plan
    terragrunt apply
    ```
  * capture the output in one file
  
### Setup eks cluster with eksctl

* go to kubernetes/dev directory from source root
* update cluster.yaml with subnet ids collected from vpc
* run create cluster command
    ```
    eksctl create cluster -f cluster.yaml
    ```

### Install MediaWiki with Helm2
```
kubectl apply -f kubernetes/helm/tiller-rbac.yaml
helm init --service-account tiller --history-max 200

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mediawiki bitnami/mediawiki
helm install --debug --atomic mediawiki2 --version 9.1.19 bitnami/mediawiki -f kubernetes/dev/mediawiki.yaml
```

### Delete 
* Delete helm release
```
helm delete mediawiki2 --purge
```
* delete PVC 
```
kubectl delete pvc data-mediawiki2-mariadb-0 mediawiki2-mediawiki
```

* delete k8s cluster
```
eksctl delete cluster kg-dev-2
```

