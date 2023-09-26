
# kuberntes

# EKS

## create cluster
```
aws eks create-cluster --name presentation-eks --kubernetes-version 1.27 \
--role-arn arn:aws:iam::920300236283:role/App_EKS_Role \
--resources-vpc-config subnetIds=subnet-064934812834958f2,subnet-043d9e03f26d127ed,subnet-040eba93b64076e3d,securityGroupIds=sg-0cde71866483edcab,endpointPublicAccess=false,endpointPrivateAccess=true \
--logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'
```


## create node

## create worker node role
https://stackoverflow.com/questions/71087365/aws-eks-cluster-nodes-creation-iam-role
trusted entity / choose AWS service / EC2
Policies:
- AmazonEKSWorkerNodePolicy
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKS_CNI_Policy
Name : App_AmazonEKSNodeRole

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
aws iam create-role   --role-name App_EKSClusterRole   --assume-role-policy-document file://"cluster-trust-policy.json"
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

## remove cluster 
kubectl config unset users.gke_project_zone_name
kubectl config unset contexts.aws_cluster1-kubernetes
kubectl config unset clusters.foobar-baz


kubectl create namespace presentation-eks
## check cluster active
aws eks describe-cluster --region eu-west-1 --name presentation-eks --query "cluster.status"



## describe cluster
kubectl get svc

## view workload
kubectl get pods -A -o wide

### delete eks cluster
aws eks delete-fargate-profile --region eu-west-1 --cluster-name presentation-eks --fargate-profile-name fp-default
eksctl delete cluster --name presentation-eks --region eu-west-3

# Kubernetes

## build 
eval $(minikube -p minikube docker-env)
I
docker build -t app2
docker tag app2:latest localhost:5000/app2:latest
docker push localhost:5000/app2:latest

## publish
export AWS_REGION=eu-west-1
export AWS_PROFILE=$(get-var AWS_PROFILE)
export AWS_ACCOUNT=$(get-var AWS_ACCOUNT_ID)
export NAMESPACE_NAME="presentation-eks"

kubectl create namespace $NAMESPACE_NAME 
kubectl create secret docker-registry regcred \
  --docker-server=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=$NAMESPACE_NAME || true 

## login to ECR
AWS_PROFILE=$(get-var AWS_PROFILE) aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker tag app2:latest ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/app2:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/app2:latest
## namespace default
kubectl config set-context --current --namespace  presentation-eks

## create
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080

kubectl create deployment app2 --image=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/app2:latest -n presentation-eks
kubectl expose deployment/app2 --type="NodePort" --port 8080

## apply deployement file
kubectl apply -f app2-deployment.yaml


## list
kubectl get deployments
kubectl get services
kubectl get pods
kubectl get events

## delete service
kubectl delete service app2
kubectl delete deployment app2
kubectl delete service kubernetes-bootcamp -n eks-sample-app
kubectl delete deployment kubernetes-bootcamp -n eks-sample-app
kubectl delete -f app1-deployment.yaml

## proxy
kubectl proxy
export POD_NAME="$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME:8080/proxy/



## blue green deployment
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
kubectl rollout status deployments/kubernetes-bootcamp

kubectl get events

kubectl create namespace fsa
kubectl create namespace eks-sample-app
kubectl apply -f eks-sample-deployment.yaml
kubectl apply -f eks-sample-service.yaml

kubectl -n eks-sample-app describe service eks-sample-linux-service
kubectl get all -n eks-sample-app
kubectl -n eks-sample-app describe pod  eks-sample-linux-deployment-f894897-dpv4v







## local registry
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  registry:2

## logging demo
```
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: busybox:1.28
    args: [/bin/sh, -c,
            'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done']
```
kubectl apply -f https://k8s.io/examples/debug/counter-pod.yaml

kubectl logs -f counter

## logging in cloud watch
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html

