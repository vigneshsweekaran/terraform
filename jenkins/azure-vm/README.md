## Terraform to create azure vm and install the Jenkins

### Generate new ssh keys locally
```
ssh-keygen -q -t rsa -N '' -f ./jenkins <<<y >/dev/null 2>&1
```

### Terraform init
```
terraform init
```

### Terraform plan
```
terraform plan \
  -out=tfplan \
  -var="resource_group_name=test"
```

### Terraform apply
```
terraform apply \
  -auto-approve \
  tfplan
```

### Terraform destroy
```
terraform destroy \
  -auto-approve \
  tfplan
```

### Terraform output
```
terraform output
```