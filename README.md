## Introduction
MediaWiki is a free software open source wiki package written in PHP.

This repository helps you to set up MediaWiki and its underlying infrastructure.

### MediaWiki Docker Image
* Build docker image
  ```
  docker build -t kusgalgangan/mediawiki:1.24.2 .
  docker push kusgalgangan/mediawiki:1.24.2
  ```
* Run docker locally
  ```
  docker run -d -p 8080:80 kusgalgangan/mediawiki:1.24.2
  ```

### Steps to Set Up Mediawiki Application
#### 1. Setup all the required tools (Optional: If you have terraform 0.12+, terragrunt 0.23+ and kubectl 1.16+ already installed)
* Install asdf, refer: https://asdf-vm.com/#/core-manage-asdf-vm
* Add asdf plugins (https://asdf-vm.com/#/plugins-all)
    ```
    asdf plugin-add terraform
    asdf plugin-add terragrunt
    asdf plugin-add kubectl
    ```
* Run `asdf install` from root of the repository.
* Install `aws-iam-authenticator` and `wget`

#### 2. Setup terragrunt
* Update config for `bucket` and `dynamodb_table` in `terraform/live/dev/terragrunt.hcl` file.
* Assumption we are using `eu-west-1` region, in case you have to change find all occurrences of it and replace.

#### 3. Setup VPC and EKS Cluster

  1. Run below commands to create VPC and Cluster together
      ```
      pushd terraform/live/dev
      terragrunt plan-all
      terragrunt apply-all
      popd
      ```

   2. Run below commands to create VPC (Optional: If setup 1 already performed)
        ```
        pushd terraform/live/dev/vpc
        terragrunt init
        terragrunt plan
        terragrunt apply
        popd
        ```
      
  3. Run below commands to create EKS Cluster (Optional: If setup 1 already performed)
        ```
        pushd terraform/live/dev/eks-cluster
        terragrunt init
        terragrunt plan
        terragrunt apply
        popd
        ```

#### 4. Install mediawiki
  * set KUBECONFIG
    ```
    export KUBECONFIG=terraform/live/dev/eks-cluster/kubeconfig_blue-kg-dev-cluster:~/.kube/config
    ```
  * Validate if all kube-system pods running
    ```
    kubectl get po -A
    ```
  * Apply MediaWiki K8s Template
    ```
      kubectl apply -f mediawiki-k8s/.
    ```
  * Check if all the pods started successfully
  * Get ELB loadbalancer endpoint
    ```
    kubectl get svc mediawiki-app
    ```
  * Open the RLB URL in browser
  * Database Details:
    - database host: mediawiki-db.default.svc.cluster.local
    - database name: bitnami_mediawiki
    - database user: bn_mediawiki
    - database password: bitnami
    
    ![Database Configuration](database-setup.png)
    
  * Mediawiki Setup completed
  ![Setup Completed](mediawiki-setup.png)
  


### How to Delete Resources
  1. Delete app
    ```
    kubectl delete -f mediawiki-k8s/.
    kubectl delete pvc appvol-mediawiki-app-0 dbvol-mediawiki-db-0
    ```
    
  2. Delete EKS Cluster and VPC in one command
        ```
        pushd terraform/live/dev
        terragrunt destroy-all
        popd
        ```
    
  3. Delete EKS Cluster (Optional: if step 2 already performed)
        ```
        pushd terraform/live/dev/eks-cluster
        terragrunt destroy
        popd
        ```
  4. Delete VPC (Optional: if step 2 already performed)
        ```
        pushd terraform/live/dev/vpc
        terragrunt destroy
        popd
        ```
