
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


## 5. EKS ingress Controller setup

[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

1. Create an IAM OIDC provider. You can skip this step if you already have one for your cluster.

```sh
eksctl utils associate-iam-oidc-provider \
    --region <region-code> \
    --cluster <your-cluster-name> \
    --approve
```

2. Download an IAM policy for the LBC using one of the following commands:
```sh
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json
```

3. Create an IAM policy named AWSLoadBalancerControllerIAMPolicy. If you downloaded a different policy, replace iam-policy with the name of the policy that you downloaded.

```sh
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```

4. Create an IAM role and Kubernetes ServiceAccount for the LBC. Use the ARN from the previous step.

```sh
eksctl create iamserviceaccount \
--cluster=<cluster-name> \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region <region-code> \
--approve
```

5 . Add the EKS chart repo to Helm

```sh
helm repo add eks https://aws.github.io/eks-charts
```

6.Helm install command for clusters with IRSA:

```sh
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<cluster-name> --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```

7. we need to provide annotations (to give power to annotations to create ALB) in ingress service section
```
 annotations:
        alb.ingress.kubernetes.io/scheme: internet-facing
		kubernetes.io/ingress.class: alb ( depressiated --> so use --> spec.ingressClassName: alb)
        alb.ingress.kubernetes.io/target-type: ip
		alb.ingress.kubernetes.io/group.name: kalyaneswar
        alb.ingress.kubernetes.io/tags: Environment=dev,Team=test
```		
	
#### aws-load-balancer-controller:

aws-load-balancer-controller-* The aws-load-balancer-controller pods in your EKS cluster are responsible for provisioning and managing AWS Elastic Load Balancers (ELBs) — specifically:


```sh
kubectl get pods -n kube-system
```

### 🚀 What It Does
The AWS Load Balancer Controller automates the creation and management of the following AWS resources:

* Application Load Balancer (ALB)

* Network Load Balancer (NLB)

### 💡 Main Functions
1. Manages Ingress Resources
It watches Kubernetes Ingress objects that are annotated to use class alb.

Then it provisions an Application Load Balancer (ALB) with necessary target groups and listener rules.

2. Manages Service of Type LoadBalancer
If you define a Service with type: LoadBalancer, and annotate it to use nlb, it provisions an NLB.

3. Dynamic Reconciliation
Continuously monitors changes to:

* Pods
* Services
* Ingress objects

Updates ALBs/NLBs accordingly (e.g., if a pod IP changes, it updates the ALB target group).

### 🔎 Why You Need It
#### Without this controller:

* You’d have to manually configure ALBs/NLBs in the AWS Console.
* You’d lose integration between Kubernetes Ingress/Service and AWS load balancing.

