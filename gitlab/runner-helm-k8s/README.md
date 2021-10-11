## Terraform script to deploy a gitlab runner on AWS EKS cluster

### Prerequisites
* EKS cluster should be already created
* If Using S3 backend for state file, s3 bucket and dynamodb should be already created.

### Command Usage with local state file
##### Terraform Init
(Option 1) Terraform init using local state file
```
terraform init
```

(Option 2) Terraform init using S3 backend state file
```
terraform init \
  -backend-config="bucket=terraform-state" \
  -backend-config="key=gitlab-runner-1/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=terraform_state" \
  -backend-config="access_key=<AWS_ACCESS_KEY_ID>" \
  -backend-config="secret_key=<AWS_SECRET_ACCESS_KEY>"
```

##### Terraform Validate
```
terraform validate
```

##### Terraform Plan
```
terraform plan \
  -var="cache_bucket_access_key=<AWS_ACCESS_KEY_ID>"
  -var="cache_bucket_secret_key=<AWS_SECRET_ACCESS_KEY>"
  -var="cache_bucket_name=<cache_bucket_name>"
  -var="eks_cluster_name=eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

##### Terraform Apply
```
terraform apply \
  -var="cache_bucket_access_key=<AWS_ACCESS_KEY_ID>" \
  -var="cache_bucket_secret_key=<AWS_SECRET_ACCESS_KEY>" \
  -var="cache_bucket_name=<cache_bucket_name>" \
  -var="eks_cluster_name=eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

##### Terraform Destroy
```
terraform destroy \
  -var="cache_bucket_access_key=<AWS_ACCESS_KEY_ID>" \
  -var="cache_bucket_secret_key=<AWS_SECRET_ACCESS_KEY>" \
  -var="cache_bucket_name=<cache_bucket_name>" \
  -var="eks_cluster_name=eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```
