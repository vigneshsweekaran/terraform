## Terraform script to create AWS Roles for EKS

### Prerequisites:
* If Using S3 backend for state file, s3 bucket and dynamodb should be already created.
* AWS credentials should be configured locally or passed via terraform commands

### Commands to run:
```
terraform init \
    -backend-config="region=us-east-1" \
    -backend-config="bucket=tf-backend-easyclaim" \
    -backend-config="key=roles/eks/terraform.tfstate" \
    -backend-config="dynamodb_table=tf-backend-easyclaim" \
    -backend-config="access_key=<access-key>" \
    -backend-config="secret_key=<secret-key>"
```
```
terraform plan \
    -var="region=us-east-1"
```
```
terraform apply \
    -var="region=us-east-1"
```
```
terraform destroy \
    -var="region=us-east-1"
```