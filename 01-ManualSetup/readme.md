
## 1. Create a workstation

 * This workstation is used to connect the cluster for deployemnts and etc..
 * Using terraform creating the ec2 instance(workstation)
    ```sh
    terraform init
    ```
    ```sh
    teraform plan
    ```
    ```sh
    terraform apply -auto-approve
    ```
 * once ec2 is launched connect with ec2 instace which is our workstation

## 2. Configure AWS with ec2(workstation)

* There are 2 ways we can configure ec2 to communicate and create AWS services/resources
    1. Attach the IAM Role to create EKS cluster or
    2. Generate AWS CLI creds to login
        ```sh
        aws configure
        ```
        ```sh
        AWS Access Key ID [None]:<AccessID>
        AWS Secret Access Key [None]:<Secret Key>
        Default region name [None]: <us-east-1>
        Default output format [None]: <NA>

        ```

## 3. Workstation setup

* Now we need to setup workstation by installing packages and others to communicate with EKS cluster
1. Install Docker
```sh
sudo sh install-docker.sh
```
2. Install eksctl 
```sh
sh eksctl-install.sh
```
3. Install kubectl
```sh
sh kubectl-install.sh
```
4. Install Helm
```sh
sh helm-install.sh
```
5. Install Kubens (to change our own ns as default)
* kubens is a tool to switch between Kubernetes namespaces (and configure them for kubectl) easily.

[Kubens-install guide/souce link](https://github.com/ahmetb/kubectx?tab=readme-ov-file#manual-installation-macos-and-linux)

```sh
sudo sh kubens-install.sh
```

## 4. Create EKS cluster Now

1. to create EKS cluster
```sh
eksctl create cluster --config-file=eks.yml
```
2. To destroy/delete EKS cluster
```sh
eksctl delete cluster --config-file=eks.yml
```

## 5. Install CSI Drivers to communicate with EBS/EFS volumes

1. Create EBS CSI Drivers

[EBS CSI GitHub Link](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md)

* Add the aws-ebs-csi-driver Helm repository.
```sh
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
```
* Install the latest release of the driver.
```sh
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver
```
* Uninstall CSI Drivers
```sh
helm uninstall aws-ebs-csi-driver --namespace kube-system
```


2. Create EFS CSI Drivers

[EFS CSI Github Link](https://github.com/kubernetes-sigs/aws-efs-csi-driver?tab=readme-ov-file)

* Add the Helm repo.
```sh
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
```

* Update the repo.
```sh
helm repo update aws-efs-csi-driver
```

* Install a release of the driver using the Helm chart.
```sh
helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
```

* Uninstall EFS CSI Drivers
```sh 
helm uninstall aws-efs-csi-driver --namespace kube-system
```

* To check CSI Drivers
```sh
kubectl get pods -n kube-system 
```