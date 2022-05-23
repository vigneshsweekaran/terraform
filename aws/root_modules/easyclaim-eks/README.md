# Terraform script to create EKS cluster

### Commands to run:
```
terraform init \
    -backend-config="region=us-west-2" \
    -backend-config="bucket=tf-remote-state20220523154219456600000001" \
    -backend-config="dynamodb_table=tf-remote-state-lock"
```

```
terraform init \
    -backend-config="region=us-west-2" \
    -backend-config="bucket=tf-remote-state20220523154219456600000001" \
    -backend-config="dynamodb_table=tf-remote-state-lock" \
    -backend-config="access_key=<access-key>" \
    -backend-config="secret_key=<secret-key>"
```

```
terraform plan
```

```
terraform apply --auto-approve
```

```
terraform destroy --auto-approve
```