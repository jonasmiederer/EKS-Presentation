cd demo

export AWS_ACCOUNT=361509912577
export AWS_REGION=eu-west-1
export ClusterName=education-eks-231012
export TF_VAR_region=$AWS_REGION
export TF_VAR_eks_cluster_name=$ClusterName

# EKS Cluster creation

create cluster
```
terraform plan --out my_plan
terraform apply my_plan
```


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

# deploy service
kubectl apply -f echoserver.yaml

# test service

## using proxy
kubectl proxy
curl http://localhost:8001/api/v1/namespaces/default/services/http:echoserver:/proxy/ | jq

## view logs
kubectl get pods
kubectl logs podname

## debug from inside
kubectl run curl --image=radial/busyboxplus:curl -i --tty --rm


# new version rollout

watch -n 1 kubectl get pods --namespace default --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image"

## rollback
kubectl rollout history deployment/echoserver
kubectl rollout undo deployment/echoserver --to-revision=2

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

kubectl apply -f myapp/myapp-deployment-v2.yaml

# ingress nginx install
https://kubernetes.github.io/ingress-nginx/deploy/ 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# ingress haproxy
https://haproxy-ingress.github.io/docs/getting-started/

kubectl --namespace default create ingress echoserver \
  --class=haproxy \
  --rule="ip-10-0-14-232.eu-west-1.compute.internal/*=echoserver:8080,tls"
kubectl --namespace default delete ingress echoserver