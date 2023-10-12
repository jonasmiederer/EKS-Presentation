---
theme: dracula
#background: https://d2908q01vomqb2.cloudfront.net/ca3512f4dfa95a03169c5a670a4c91a19b3077b4/2018/08/23/eks-orig.jpg
class: text-center
highlighter: shiki
lineNumbers: false
info: |
  ## Slidev Starter Template
  Presentation slides for developers.

  Learn more at [Sli.dev](https://sli.dev)
drawings:
  persist: false
transition: slide-left
title: "EKS : Kubernetes on AWS"
hideInToc: true
---


<img src="https://media.geeksforgeeks.org/wp-content/cdn-uploads/20220306133735/Group-42.jpg" style="width:40%;display: block;margin-left: auto; margin-right: auto;border-radius: 25px;"/>

2023/10/13 

Jonas Miederer

Florent Sithimolada


<!-- <div class="pt-12">
  <span @click="$slidev.nav.next" class="px-2 py-1 rounded cursor-pointer" hover="bg-white bg-opacity-10">
    Press Space for next page <carbon:arrow-right class="inline"/>
  </span>
</div>

<div class="abs-br m-6 flex gap-2">
  <button @click="$slidev.nav.openInEditor()" title="Open in Editor" class="text-xl slidev-icon-btn opacity-50 !border-none !hover:text-white">
    <carbon:edit />
  </button>
  <a href="https://github.com/slidevjs/slidev" target="_blank" alt="GitHub"
    class="text-xl slidev-icon-btn opacity-50 !border-none !hover:text-white">
    <carbon-logo-github />
  </a>
</div> -->

<!--
The last comment block of each slide will be treated as slide notes. It will be visible and editable in Presenter Mode along with the slide. [Read more in the docs](https://sli.dev/guide/syntax.html#notes)
-->

---
layout: default
transition: fade-out
hideInToc: true
---

<h3>Disclaimer</h3>

This presentation provides just a small glimpse (teaser) of the whole Kubernetes and EKS ecosystem.

---
layout: default
transition: fade-out
hideInToc: true
---

# Table of contents

<Toc maxDepth="2" columns="2"></Toc>

---
transition: slide-left
title: Kubernetes
level: 0
layout: center
class: text-center
---

# Kubernetes

What is Kubernetes and how can we use it?

---
transition: slide-left
---

## What is Kubernetes (K8s)?

- Providing automated container orchestration, Kubernetes improves your reliability and reduces the time and resources attributed to daily operations.
- Originally developed at Google and released as open source in 2014. Now it's maintained by the CNCF (Cloud Native Computing Foundation).
- Name comes from acient greek word kubernḗtēs (*navigator* or *guide*)
- Deploy, scale & manage containerized workloads anywhere

Features that Kubernetes provides:

- Infrastructure abstraction
- Automated operations
- Service health monitoring
- Made for microservice applications


---
transition: slide-left
layout: two-cols
---

## How does Kubernetes work?


<img
  src="https://www.cncf.io/wp-content/uploads/2020/09/Kubernetes-architecture-diagram-1-1-1024x698.png"
/>

::right::

<style>
#k8s-architecture  {
  /* margin-left: 10px; */
  font-size: 1rem;
}
</style>

<div id="k8s-architecture">

- Kubernetes consists of a network of *nodes*
- Control Plane (*master node*): K8s management
  - API server: provides internal & external APIs via HTTP (JSON)
  - Scheduler: Assigns & schedules a certain unscheduled pod to a node
  - Controller: Loop process that is responsible for achieving the desired state of the cluster. The controller manager manages a set of controllers
  - etcd: Lightweight distributed key-value store to keep the configuration data of the cluster
- Nodes (*worker node*): Run workloads
  - kubelet: Observing and managing the running state of each node
  - kube-proxy: Network proxy and load balancer to ensure communication between nodes, responsible for name resolving and routing

</div>



---
transition: slide-up
---

## Building blocks

Kubernetes infrastructures consist of single building blocks (resources) that are combined together to create a scalable, secure and resilient platform for application deployments.

The whole kubernetes environment is described in a *declarative* manner. We define how the target state should look like, the process of reaching that state is the job of the kubernetes control plane.

Usually, the kubernetes objects / resources are defined in *.yml* format, so they are easy to read, create and process for humans as well as computers.
---
transition: slide-up
---

### Namespace

Grouping and managing different resources in namespaces helps to organize the cluster. It can be scoped by responsibilities, domains, teams or other strategies. If not specified otherwise, resources will be created in the *default* namespace. 

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    name: development
```
---
transition: slide-up
---

### Pods

The smallest deployable units in K8s are pods. It contains/manages one or more containers running on the same node with shared storage and network resources. It resembles a 'logical host' (i.e. tightly coupled containers).

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```
---
transition: slide-up
---

### Deployments

Deployments describe a desired state, which the Deployment Controller uses in order to change the actual state to the desired state at a controlled rate. It provides features such as rolling updates, rollbacks, self-healing capabilities, etc. 

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80
```
---
transition: slide-up
---

### Services

A service can be used to expose an application running as one or more pods in your cluster. The services are assigned a stable IP address and a DNS name for communication in the cluster. It also provides load balancing among the pods of the same selector.

```yml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
---
transition: slide-left
---

### Ingress

Exposes HTTP & HTTPS routes from outside the cluster to services within the cluster. The routing behaviour can be configured and controlled by rules defined on the ingress resource.


```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

---
transition: slide-up
---

## Kubernetes API 

You can interact with the kubernetes control plane via the exposed Kubernetes API.

<br/>

You can either use the API directly via HTTPS requests, or you can use the *kubectl* command line tool. After authorization, `kubectl` is fairly simple to use with a clear syntax:

```bash
kubectl [command] [TYPE] [NAME] [flags]
```
---
transition: slide-left
---

### Kubernetes API - Examples

```bash
kubectl get pods
```
List all pods in current namespace

```bash
kubectl describe [NAME]
```
Display the detailed state for one or more resources

```bash
kubectl exec POD [...]
```
Execute a command against a container in a pod

```bash
kubectl logs POD [...]
```
Display the logs for a container in a pod

```bash
kubectl create -f FILENAME
```
Creates a kubernetes resource from a file or stdin

```bash
kubectl apply -f FILENAME
```
Apply a configuration change to a resource from a file or stdin

---
transition: slide-left
---

## Cluster access

- `kubectl proxy`: Starts a proxy to the K8s API server in order to communicate with the API for example via curl, wget, ...
- `kubectl port-forward`: Tunnels specific local port to the port of a pod/service in the cluster 
- `kubefwd`: Create port forwarding for en entire namespace automatically and managing your local host file to resolve DNS names
---
transition: slide-left
---

## Deployment scripting

- kubctl command: Command line to create deployment, service etc...
- kubctl yaml file: Deployment as code
- Helm : Package manager for Kubernetes. Helm Chart is a like a .rpm or .deb file.
- Terraform: Can manage Kubernetes resources and Helm charts as well


---
transition: slide-left
title: EKS
layout: center
class: text-center
---

# EKS

What is EKS and how can we use it?
---
transition: slide-left
---

## What is EKS

Elastic Kubernetes Service (EKS) is the managed Kubernetes service provided by AWS. It automatically manages the availability & scalability of the Kubernetes control plane nodes, storing cluster data etc. 

<br/>

A big advantage of EKS compared to self-managed Kubernetes is the simple *integration with other 
AWS services*, such as networking and security (VPC, IAM, EC2, EBS, ...)


---
transition: slide-left
---


## Node provisioning

EKS provides two different approaches to compute resources:

- **AWS EC2**: Cluster is self-managed, nodes are provided by user as EC2 instances
```
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
```


- **AWS Fargate**: Serverless approach, infrastructre is hidden/abstracted away from the user. Fargate dynamically allocates resources. Possible Mapping 1 Pod = 1 fargate 

```bash
eksctl create cluster --name my-cluster --region region-code --fargate
```
Fargate Profile

Selector : defined at node group and fargate profile level. They match service or pod's labels and namespace to determine in which type of node need to be provisioned

---
transition: slide-left
---

## EC2 vs Fargate

- EC2++ : EC2 is a bit **cheaper**
- EC2++ : In EKS Fargate each pod is run in its own VM and **container images are not cached on nodes**, making the startup times for pods 1-2 minutes long
- Fargate-- : **Daemonsets are not supported in EKS Fargate**, so observability tools like Fluentbit, Splunk and Datadog have to **run in sidecar containers** in each pod instead of a daemonset per node

---
transition: slide-left
---

## Auto scaling

- Kubernetes Cluster Autoscaler (SIG) : Stable and robust. Can only handle one kind of resources. 
- Karpenter (AWS) : Cost optimisation in mind. Start any kind of EC2 instances. Always try to reorganize pods and nodes.

---
transition: slide-left
---

## Security : IAM least priviledge principle

IAM role can be define at
- Managed node group level : like IAM Role for an EC2
- Service level  with : IAM roles for K8s service accounts. Pods make signed call 

---
transition: slide-left
---

## Load balancing

EKS plugable with :
- ALB (Layer 7), url routing, TLS Termination, Certificate Manager, Client information IP, Proto
- NLB (Layer 4), faster, cheaper

---
transition: slide-left
---

## Logging to Cloud Watch

Application logs are kept in k8s cluster. 
Push to Cloud watch required logging and metrics processor and forwarder : Fluent bit (recommended). Deployed as a Deamonset

Deploy code at Node level for mutualisation

---
transition: slide-left
---

## Cost monitoring

Amazon EKS supports Kubecost : Break down costs by namespace, deployment, service, and more across any major cloud provider or on-prem Kubernetes environment. Prometeus Graphana based
<img
  src="https://docs.aws.amazon.com/images/eks/latest/userguide/images/kubecost.png"
/>


---
transition: slide-left
---

# Demo

- Terraform provisioning
- EKS console overview
- Logging with Fluentbit
- Deploy, Test, Debug
- Deployment / rollout



---
transition: slide-left
---

# Conclusion

Cons:

- complexity : tonnes of new concepts, need to link them to AWS concepts too.
- many ways to perform the same action : aws cli eks, eksctl, terraform.
- sanofi context : any eks iam  role creation script are working out of the box.

Pros:

- Deployment of pods is fast.
- Accessing the pods and getting logs are easy
- AWS provide a nice Web Console to browse easily
- Services like fluenbit are deploy quickly


---
transition: slide-left
---

# TODO

- Install Ingress ALB
- Finish terraform update to make it Compatible with Sanofi IAM role creation process, 
- Install Kubernetes Cluster Autoscaler (SIG)


- give a try to kOps : EKS alternative that create production kubernetes cluster with provisioning cloud infrastructure on any provider (AWS GCE DigitalOcean (official), Hetzner OpenStack (Beta), Azure (alpha)

---
transition: slide-left
---

## EKS & K8s in the context of the AWS Well-Architected Framework

- **Operational Excellence** 
  - Perform operations as code: yaml files
  - Make frequent, small, reversible changes: K8s takes care of updating only the changed components
  - Anticipate failure: Make services redundant
- **Security**
  - Apply security at all layers : Pod Security Admission (PSA) & Pod Security Standards (PSS): Define capabilities, privileges & configurations (SELinux, runAsUser, ...)
  - Keep people away from data : Mount secrets (Secrets Manager) & parameters (Parameter Store) into EKS pods via AWS Secrets and Configuration Provider (ASCP)
  - Implement a strong identity foundation : Access to the cluster using IAM principals is enabled by the AWS IAM Authenticator for Kubernetes, which runs on the Amazon EKS control plane. The authenticator gets its configuration information from the `aws-auth` ConfigMap
  - Enable traceability : EKS CloudWatch CloudTrail logs

---
transition: slide-left
---

- **Reliability**
  - Automatically recover from failure : kubernetes basic
  - Scale horizontally to increase aggregate workload availability : 
    - EKS runs control plane across 3 AZ in an AWS Region. It automatically manages the availability and scalability of the Kubernetes API servers and the etcd cluster.
    - Fargate handles provisioning and scaling of the data plane. With self-managed nodes the responsibility shifts to the user.
    - Schedule replicas across nodes
    - Use EC2 Auto Scaling Groups to create worker nodes

- **Performance Efficiency**
  - Democratize advanced technologies : use latest (cheaper) EC2 instances type and k8s will migrate pods to it with ease.
  - Experiment more often : with K8s Canary deployment is easy

---
transition: slide-left
---

- **Cost Optimization**
  - Implement cloud financial management
  - Analyze and attribute expenditure: 
    - Instance Tagging
    - Use Kubecost
  - Fine tune performance vs cost 
    - EC2 node sizing
    - Evaluate Compute / Networking / Storage Costs
    - Cluster Autoscaler

- **Sustainability**
  - Utilization & scaling capabilities of K8s : adapt provisioning to workload
  - Choose sustainable AWS regions : co² footprint


---
transition: slide-left
---
# Sources

**AWS**
- The 6 Pillars of the AWS Well-Architected Framework: https://aws.amazon.com/blogs/apn/the-6-pillars-of-the-aws-well-architected-framework/

**Kubernetes**
- https://kubernetes.io/docs/reference
- https://www.cncf.io/blog/2019/08/19/how-kubernetes-works/
- https://aws.amazon.com/eks/

---
transition: slide-left
---

**EKS**
- EKS Best Practices: https://aws.github.io/aws-eks-best-practices
- Great and complete Tutorials: https://www.youtube.com/@AntonPutra
- EKS Load balancing: https://blog.getambassador.io/configuring-kubernetes-ingress-on-aws-dont-make-these-mistakes-1a602e430e0a
- IAM Role at Pods level: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
- EKS provisionning: https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks
- Logging to Cloudwatch with fluetbit
  - https://docs.aws.amazon.com/fr_fr/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html
  - https://blog.getambassador.io/configuring-kubernetes-ingress-on-aws-dont-make-these-mistakes-1a602e430e0a

---
layout: center
class: text-center
---

# Thank you

Questions?