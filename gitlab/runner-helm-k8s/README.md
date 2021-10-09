## Terraform script to deploy a gitlab runner on kubernetes cluster

### Prerequisites
AWS credentials AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY should be already configured

### Command Usage with local state file
Init a terraform
```
terraform init
```

validate a terraform script
```
terraform validate
```

Plan
```
terraform plan \
  -var="eks_cluster_name=eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

Apply
```
terraform apply \
  -var eks_cluster_name-"eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

Destroy
```
terraform destroy \
  -var eks_cluster_name-"eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

### Command Usage with S3 backend state file
Init a terraform
```
terraform init \
  -backend-config="key=roles/terraform.tfstate" \
  -backend-config="dynamodb_table=terraform_state-dynamodb" \
  -backend-config="access_key=<access-key>" \
  -backend-config="secret_key=<secret-key>"
```

validate a terraform script
```
terraform validate
```

Plan
```
terraform plan \
  -var="eks_cluster_name=eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

Apply
```
terraform apply \
  -var eks_cluster_name-"eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```

Destroy
```
terraform destroy \
  -var eks_cluster_name-"eks-cluster" \
  -var="runner_registration_token=<runner-token>"
```
