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
---


<img src="https://media.geeksforgeeks.org/wp-content/cdn-uploads/20220306133735/Group-42.jpg" style="width:40%;display: block;margin-left: auto; margin-right: auto;border-radius: 25px;"/>

2023/09/29 

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
---

# Table of contents

<Toc maxDepth="1"></Toc>

---
transition: slide-left
---

# What is Kubernetes (K8s)?

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

level: 2
layout: two-cols
---

# How does Kubernetes work?


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

# Building blocks

Kubernetes infrastructures consist of single building blocks (resources) that are combined together to create a scalable, secure and resilient platform for application deployments.

The whole kubernetes environment is described in a *declarative* manner. We define how the target state should look like, the process of reaching that state is the job of the kubernetes control plane.

Usually, the kubernetes objects / resources are defined in *.yml* format, so they are easy to read, create and process for humans as well as computers.
---
transition: slide-up
---

## Namespace

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

## Pods

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

## Deployments

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

## Services

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

## Ingress

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
transition: slide-left
---

# Kubernetes API 

You can interact with the kubernetes control plane via the exposed Kubernetes API.

<br/>

You can either use the API directly via HTTPS requests, or you can use the *kubectl* command line tool. After authorization, `kubectl` is fairly simple to use with a clear syntax:

```bash
kubectl [command] [TYPE] [NAME] [flags]
```
---
transition: slide-left
---

# Kubernetes API - Examples

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

# EKS

Elastic Kubernetes Service (EKS) is the managed Kubernetes service provided by AWS. It automatically manages the availability & scalability of the Kubernetes control plane nodes, storing cluster data etc. 

<br/>

A big advantage of EKS compared to self-managed Kubernetes is the simple *integration with other AWS services*, such as networking and security (VPC, IAM, EC2, EBS, ...)

## Approaches

EKS provides two different approaches to compute resources:

- **AWS EC2**: Cluster is self-managed, nodes are provided by user as EC2 instances
- **AWS Fargate**: Serverless approach, infrastructre is hidden/abstracted away from the user. Fargate dynamically allocates resources.

```bash
eksctl create cluster --name my-cluster --region region-code --fargate
```
---
transition: slide-left
---

# Sources 

- https://kubernetes.io/docs/reference
- https://www.cncf.io/blog/2019/08/19/how-kubernetes-works/
- https://aws.amazon.com/eks/

---
layout: center
class: text-center
---

# Thank you

Questions?