
# kuberntes

# EKS

## create cluster

not working on sanofi used manual creation with App_EKS_Role
```
eksctl create cluster \
--name presentation-eks \
--region eu-west-1 \
--version 1.27 \
--authenticator-role-arn arn:aws:iam::920300236283:role/App_EKS_Role \
--vpc-private-subnets subnet-064934812834958f2,subnet-043d9e03f26d127ed,subnet-040eba93b64076e3d \
--node-security-groups sg-0cde71866483edcab \
--ssh-access \
--ssh-public-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcjJobjB0/5AGreNJ1+gXkeaGfB6eBFztMrDgiXcttM Florent.sithimolada-ext@sanofi.com key2" \
--without-nodegroup
```

## create node
eksctl create nodegroup \
  --cluster presentation-eks \
  --region eu-west-1 \
  --name presentation-eks \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --ssh-access \
  --managed=false \
  --subnet-ids subnet-064934812834958f2,subnet-043d9e03f26d127ed,subnet-040eba93b64076e3d \
  --ssh-public-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcjJobjB0/5AGreNJ1+gXkeaGfB6eBFztMrDgiXcttM Florent.sithimolada-ext@sanofi.com key2"

Error: loading VPC spec for cluster "presentation-eks": VPC configuration required for creating nodegroups on clusters not owned by eksctl: vpc.subnets, vpc.id, vpc.securityGroup


### create role


create file : cluster-trust-policy.json 
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```
aws iam create-role   --role-name eksClusterRole   --assume-role-policy-document file://"cluster-trust-policy.json"
```

```
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name eksClusterRole
```

### create iadc App_EKS_Role


### tips
not working because App_ role need to be created
```eksctl create cluster --name presentation-eks --region eu-west-1 --fargate```
create a cluster in the aws console named presentation-eks
install kubectl https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
install eksctl https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

## access the cluster
usfull https://repost.aws/knowledge-center/eks-cluster-connection

check iam role ```aws sts get-caller-identity```
### Create or update the kubeconfig (add the cluter to kubectl) a.k.a login to cluster
```
eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=eu-west-3 --cluster=presentation-eks
```
```
aws eks --region eu-west-1 update-kubeconfig --name presentation-eks
cat /home/ec2-user/.kube/config
```


### delete old cluster
```kubectl config delete-cluster cluster_name```

eksctl delete cluster --region=eu-west-3 --name=presentation-eks


## list cluster and context
kubectl config get-contexts


kubectl create namespace presentation-eks
## check cluster active
aws eks describe-cluster --region eu-west-1 --name presentation-eks --query "cluster.status"



## describe cluster
kubectl get svc

## view workload
kubectl get pods -A -o wide


# Kubernetes


kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080

kubectl get deployments
kubectl get services

kubectl proxy
export POD_NAME="$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME:8080/proxy/

kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
kubectl rollout status deployments/kubernetes-bootcamp

kubectl get events


kubectl create namespace eks-sample-app
kubectl apply -f eks-sample-deployment.yaml
kubectl apply -f eks-sample-service.yaml

kubectl -n eks-sample-app describe service eks-sample-linux-service
kubectl get all -n eks-sample-app
kubectl -n eks-sample-app describe pod  eks-sample-linux-deployment-f894897-dpv4v



### delete service
kubectl delete service kubernetes-bootcamp -n eks-sample-app
kubectl delete deployment kubernetes-bootcamp -n eks-sample-app

### delete eks cluster
aws eks delete-fargate-profile --region eu-west-1 --cluster-name presentation-eks --fargate-profile-name fp-default
eksctl delete cluster --name presentation-eks --region eu-west-3
