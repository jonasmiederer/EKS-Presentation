cd demo

export AWS_ACCOUNT=361509912577
export AWS_REGION=eu-west-1

# EKS Cluster creation

create cluster
```
terraform plan --out my_plan
terraform apply my_plan
```
export ClusterName=education-eks-M70L6nwO

aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)

# logging in cloudwatch


create amazon-cloudwatch namespace
```
kubectl apply -f amazon-cloudwatch-namespace.yaml
or
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/ daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```

create Fluent bit configMap
```
ClusterName=${ClusterName}
RegionName=${AWS_REGION}
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
```

Download and deploy the Fluent Bit daemonset
```
kubectl apply -f fluentbit.yaml
or
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

configmap of fluentby o redirect to cloudwatch
```
kubectl apply -f aws-logging.yaml
```


# Build HTTP App and publish to ECR

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

for v in 1 2
do
  docker build -t ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/myapp:v$v -f myapp/Dockerfile.myapp-v$v myapp
  docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/myapp:v$v
done 

# create deployment and service
kubectl apply -f myapp/myapp-deployment-v1.yaml
<!-- 
  kubectl create deployment app2 --image=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/app2:latest
  kubectl expose deployment/app2 --type="NodePort" --port 8082 --target-port=3000
-->

# new version rollout

watch -n 1 kubectl get pods --namespace default --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image"


kubectl apply -f myapp/myapp-deployment-v2.yaml

kubectl run curl --image=radial/busyboxplus:curl -i --tty --rm

curl myapp:8082


