## Terraform script to create AWS EKS cluster

### Prerequisites:
* This terraform script should be executed from linux machine
* If Using S3 backend for state file, s3 bucket and dynamodb should be already created.
* AWS credentials should be configured locally or passed via terraform commands
* Replace <acc-id> with AWS account id terraform commands
* Update cluster_name, region, vpc_id, public_subnet1_id, public_subnet2_id, private_subnet1_id and private_subnet2_id in input.json
* Update the required namespace value for fargate profile in fp_namespaces in dev1/dev2.tfvars file

### Post activities
* Add tag kubernetes.io/role/internal-elb = 1 in all subnets, then only aws lb controller can create the load balancer

### Information about created EKS Cluster
* Create one nodegroup and one Fargate profile
* Nodegroup with minimum 2 and maximum 3 nodes
* Fargate profile watches default and gitlab-runner namespace
* AWS ALB Ingress controller is configured

### Information about EKS Fargate
* Daemonsets are not supported in in EKS Fargate
* Public subnets are not allowed, only private subnets are allowed.
* Privileged containers are not allowed

### Known Issues
* After deploying the pod in Fargate node, if we update the Fargate profile selector and do terraform apply, the fargate profile be destroyed and recreated and the running pods in Fargate will be in Pending state. (This is a expected behaviour as per AWS Documemtaion)

### Commands to run:
```
terraform init \
    -backend-config="region=us-east-1" \
    -backend-config="bucket=tf-backend-easyclaim" \
    -backend-config="key=eks/gitlab-runner/terraform.tfstate" \
    -backend-config="dynamodb_table=tf-backend-easyclaim" \
    -backend-config="access_key=<access-key>" \
    -backend-config="secret_key=<secret-key>"
```
```
terraform plan \
    -var="region=us-east-1" \
    -var="eks_cluster_role=arn:aws:iam::<acc-id>:role/eks-cluster-role" \
    -var="eks_node_group_role=arn:aws:iam::<acc-id>:role/eks-node-group-role" \
    -var="fargate_pod_execution_role=arn:aws:iam::<acc-id>:role/eks-fargate-pod-execution-role"
```
```
terraform apply \
    -var="region=us-east-1" \
    -var="eks_cluster_role=arn:aws:iam::<acc-id>:role/eks-cluster-role" \
    -var="eks_node_group_role=arn:aws:iam::<acc-id>:role/eks-node-group-role" \
    -var="fargate_pod_execution_role=arn:aws:iam::<acc-id>:role/eks-fargate-pod-execution-role"
```
```
terraform destroy \
    -var="region=us-east-1" \
    -var="eks_cluster_role=arn:aws:iam::<acc-id>:role/eks-cluster-role" \
    -var="eks_node_group_role=arn:aws:iam::<acc-id>:role/eks-node-group-role" \
    -var="fargate_pod_execution_role=arn:aws:iam::<acc-id>:role/eks-fargate-pod-execution-role"
```
